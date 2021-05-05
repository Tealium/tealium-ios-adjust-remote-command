//
//  AdjustRemoteCommand.swift
//  TealiumAdjust
//
//  Created by Christina S on 2/10/21.
//

import os
import Foundation
#if canImport(Adjust)
import Adjust
#else
import AdjustSdk
#endif
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
import TealiumRemoteCommands
#endif

public class AdjustRemoteCommand: RemoteCommand {
    
    var adjustInstance: AdjustCommand?
    private var loggerLevel: TealiumLogLevel = .error
    public weak var adjustDelegate: (AdjustDelegate & NSObjectProtocol)?
    
    public var trackingAuthorizationCompletion: ((UInt) -> Void)? {
        willSet {
            if let newValue = newValue {
                adjustInstance?.requestTrackingAuthorization(with: newValue)
            }
        }
    }
    
    public init(adjustInstance: AdjustCommand = AdjustInstance(),
                type: RemoteCommandType = .webview) {
        self.adjustInstance = adjustInstance
        weak var weakSelf: AdjustRemoteCommand?
        super.init(commandId: AdjustConstants.commandId,
                   description: AdjustConstants.description,
            type: type,
            completion: { response in
                guard let payload = response.payload else {
                    return
                }
                weakSelf?.processRemoteCommand(with: payload)
            })
        weakSelf = self
    }

    public func processRemoteCommand(with payload: [String: Any]) {
        guard let adjustInstance = adjustInstance,
            let command = payload[AdjustConstants.commandName] as? String else {
                return
        }
        let commands = command.split(separator: AdjustConstants.separator)
        let adjustCommands = commands.map { command in
            return command.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        loggerLevel = logLevel
        adjustCommands.forEach {
            let command = AdjustConstants.Commands(rawValue: $0.lowercased())
            switch command {
            case .initialize:
                guard let apiToken = payload[AdjustConstants.Keys.apiToken] as? String else {
                    log("\(AdjustConstants.Keys.apiToken) required.")
                    return
                }
                let sandbox = payload[AdjustConstants.Keys.sandbox] as? Bool ?? false
                let settings = payload[AdjustConstants.Keys.settings] as? [String: Any] ?? [String: Any]()
                initialize(apiToken: apiToken, sandbox: sandbox, settings: settings)
            case .trackEvent:
                guard let eventToken = payload[AdjustConstants.Keys.eventToken] as? String else {
                    log("\(AdjustConstants.Keys.eventToken) required.")
                    return
                }
                let revenue = payload[AdjustConstants.Keys.revenue] as? Double
                let currency = payload[AdjustConstants.Keys.currency] as? String
                let transactionId = payload[AdjustConstants.Keys.orderId] as? String
                let callbackId = payload[AdjustConstants.Keys.callbackId] as? String
                let callbackParams = payload[AdjustConstants.Keys.callbackParameters] as? [String: String]
                let partnerParams = payload[AdjustConstants.Keys.partnerParameters] as? [String: String]
                
                sendEvent(eventToken, transactionId: transactionId, revenue: revenue, currency: currency, callbackParams: callbackParams, partnerParams: partnerParams, callbackId: callbackId)
            case .trackSubscription:
                guard let price = payload[AdjustConstants.Keys.revenue] as? Double,
                      let currency = payload[AdjustConstants.Keys.currency] as? String,
                      let transactionId = payload[AdjustConstants.Keys.orderId] as? String else {
                    log("revenue, currency, and order_id required")
                    return
                }
                guard let receipt = payload[AdjustConstants.Keys.receipt] as? Data ?? appStoreReiept else {
                    log("\(AdjustConstants.Keys.receipt) required")
                    return
                }
                let salesRegion = payload[AdjustConstants.Keys.salesRegion] as? String
                let purchaseTime = payload[AdjustConstants.Keys.purchaseTime] as? Double ?? 0.0
                let callbackParams = payload[AdjustConstants.Keys.callbackParameters] as? [String: String]
                let partnerParams = payload[AdjustConstants.Keys.partnerParameters] as? [String: String]
                
                trackSubscription(price: price, currency: currency, transactionId: transactionId, receipt: receipt, transactionDate: Date(timeIntervalSince1970: purchaseTime), salesRegion: salesRegion, callbackParams: callbackParams, partnerParams: partnerParams)
            case .updateConversionValue:
                guard let conversionValue = payload[AdjustConstants.Keys.conversionValue] as? Int else {
                    log("\(AdjustConstants.Keys.conversionValue) required")
                    return
                }
                adjustInstance.updateConversionValue(conversionValue)
            case .appWillOpenUrl:
                guard let urlString = payload[AdjustConstants.Keys.deeplinkOpenUrl] as? String,
                      let url = URL(string: urlString) else {
                    log("\(AdjustConstants.Keys.deeplinkOpenUrl) required")
                    return
                }
                adjustInstance.appWillOpen(url)
            case .trackAdRevenue:
                guard let source = payload[AdjustConstants.Keys.adRevenueSource] as? String,
                      let payload = payload[AdjustConstants.Keys.adRevenuePayload] as? [String: Any] else {
                    log("\(AdjustConstants.Keys.adRevenueSource) and \(AdjustConstants.Keys.adRevenuePayload) required")
                    return
                }
                adjustInstance.trackAdRevenue(source, payload: payload)
            case .setPushToken:
                guard let token = payload[AdjustConstants.Keys.pushToken] as? String else {
                    log("\(AdjustConstants.Keys.pushToken) required")
                    return
                }
                adjustInstance.setPushToken(token)
            case .setEnabled:
                guard let enabled = payload[AdjustConstants.Keys.enabled] as? Bool else {
                    log("\(AdjustConstants.Keys.enabled) required")
                    return
                }
                adjustInstance.setEnabled(enabled)
            case .setOfflineMode:
                guard let enabled = payload[AdjustConstants.Keys.enabled] as? Bool else {
                    log("\(AdjustConstants.Keys.enabled) required")
                    return
                }
                adjustInstance.setOfflineMode(enabled: enabled)
            case .gdprForgetMe:
                adjustInstance.gdprForgetMe()
            case .setThirdPartySharing:
                guard let enabled = payload[AdjustConstants.Keys.enabled] as? Bool else {
                    log("\(AdjustConstants.Keys.enabled) required")
                    return
                }
                adjustInstance.trackThirdPartySharing(enabled: enabled)
            case .trackMeasurementConsent:
                guard let consented = payload[AdjustConstants.Keys.measurementConsent] as? Bool else {
                    log("\(AdjustConstants.Keys.measurementConsent) required")
                    return
                }
                adjustInstance.trackMeasurementConsent(consented: consented)
            case .addSessionCallbackParams:
                guard let callbackParams = payload[AdjustConstants.Keys.sessionCallbackParameters] as? [String: String] else {
                    log("\(AdjustConstants.Keys.sessionCallbackParameters) required")
                    return
                }
                adjustInstance.addSessionCallbackParams(callbackParams)
            case .removeSessionCallbackParams:
                guard let paramNames = payload[AdjustConstants.Keys.removeSessionCallbackParameters] as? [String] else {
                    log("\(AdjustConstants.Keys.removeSessionCallbackParameters) required")
                    return
                }
                adjustInstance.removeSessionCallbackParams(paramNames)
            case .resetSessionCallbackParams:
                adjustInstance.resetSessionCallbackParams()
            case .addSessionPartnerParams:
                guard let parnterParams = payload[AdjustConstants.Keys.sessionPartnerParameters] as? [String: String] else {
                    log("\(AdjustConstants.Keys.sessionPartnerParameters) required")
                    return
                }
                adjustInstance.addSessionPartnerParams(parnterParams)
            case .removeSessionPartnerParams:
                guard let paramNames = payload[AdjustConstants.Keys.removeSessionPartnerParameters] as? [String] else {
                    log("\(AdjustConstants.Keys.removeSessionPartnerParameters) required")
                    return
                }
                adjustInstance.removeSessionPartnerParams(paramNames)
            case .resetSessionPartnerParams:
                adjustInstance.resetSessionPartnerParams()
            default:
                break
            }
        }
    }
    
    public func initialize(apiToken: String, sandbox: Bool, settings: [String : Any]) {
        let environment = sandbox ? ADJEnvironmentSandbox : ADJEnvironmentProduction
        let logLevel = ADJLogLevel(from: settings[AdjustConstants.Keys.logLevel] as? String)
        guard let config = ADJConfig(appToken: apiToken, environment: environment) else {
            return
        }
        config.logLevel = logLevel
        config.delegate = adjustDelegate
        if let delayStartTime = settings[AdjustConstants.Keys.delayStart] as? Double {
            config.delayStart = delayStartTime
        }
        if let appSecret = settings[AdjustConstants.Keys.secretId] as? Int {
            let secrets = Secrets(from: settings)
            config.setAppSecret(UInt(appSecret), info1: secrets.one, info2: secrets.two, info3: secrets.three, info4: secrets.four)
        }
        if let defaultTracker = settings[AdjustConstants.Keys.defaultTracker] as? String {
            config.defaultTracker = defaultTracker
        }
        if let externalDeviceId = settings[AdjustConstants.Keys.externalDeviceId] as? String {
            config.externalDeviceId = externalDeviceId
        }
        if let eventBufferingEnabled = settings[AdjustConstants.Keys.eventBufferingEnabled] as? Bool {
            config.eventBufferingEnabled = eventBufferingEnabled
        }
        if let sendInBackground = settings[AdjustConstants.Keys.sendInBackground] as? Bool {
            config.sendInBackground = sendInBackground
        }
        if let residency = settings[AdjustConstants.Keys.urlStrategy] as? String {
            config.urlStrategy = residency
        }
        config.allowiAdInfoReading = settings[AdjustConstants.Keys.allowiAdInfoReading] as? Bool ?? false
        config.allowAdServicesInfoReading = settings[AdjustConstants.Keys.allowAdServicesInfoReading] as? Bool ?? false
        config.allowIdfaReading = settings[AdjustConstants.Keys.allowIdfaReading] as? Bool ?? false
        let isSKAdNetworkHandlingActive = settings[AdjustConstants.Keys.isSKAdNetworkHandlingActive] as? Bool ?? true
        if !isSKAdNetworkHandlingActive {
            config.deactivateSKAdNetworkHandling()
        }
        adjustInstance?.initialize(with: config)
    }
    
    public func sendEvent(_ token: String,
                          transactionId: String?,
                          revenue: Double?,
                          currency: String?,
                          callbackParams: [String : String]?,
                          partnerParams: [String : String]?,
                          callbackId: String?) {
        guard let event = ADJEvent(eventToken: token) else {
            return
        }
        if let transactionId = transactionId {
            event.setTransactionId(transactionId)
        }
        if let revenue = revenue,
           let currency = currency {
            event.setRevenue(revenue, currency: currency)
        }
        callbackParams?.forEach {
            event.addCallbackParameter($0.key, value: $0.value)
        }
        partnerParams?.forEach {
            event.addPartnerParameter($0.key, value: $0.value)
        }
        if let callbackId = callbackId {
            event.setCallbackId(callbackId)
        }
        adjustInstance?.sendEvent(event)
    }
    
    public func trackSubscription(price: Double,
                                  currency: String,
                                  transactionId: String,
                                  receipt: Data,
                                  transactionDate: Date?,
                                  salesRegion: String?,
                                  callbackParams: [String : String]?,
                                  partnerParams: [String : String]?) {
        guard let subscription = ADJSubscription(price: NSDecimalNumber(value: price),
                                                 currency: currency,
                                                 transactionId: transactionId,
                                                 andReceipt: receipt) else {
            return
        }
        if let salesRegion = salesRegion {
            subscription.setSalesRegion(salesRegion)
        }
        callbackParams?.forEach {
            subscription.addCallbackParameter($0.key, value: $0.value)
        }
        partnerParams?.forEach {
            subscription.addPartnerParameter($0.key, value: $0.value)
        }
        subscription.setTransactionDate(transactionDate ?? Date())

        adjustInstance?.trackSubscription(subscription)
    }
    
    private var appStoreReiept: Data? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
               return try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
            }
            catch {
                log("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        }
        return nil
    }
    
    private var logLevel: TealiumLogLevel {
        guard let tealium = TealiumInstanceManager.shared.tealiumInstances.first?.value,
              let environment = tealium.dataLayer.all[TealiumKey.environment] as? String else {
            return .error
        }
       return environment == "prod" ? TealiumLogLevel(from: "error") : TealiumLogLevel(from: "info")
    }
    
    private func log(_ message: String) {
        os_log("%{public}@",
               type: OSLogType(UInt8(loggerLevel.rawValue)),
               "\(AdjustConstants.description): \(message)")
    }
    
}

fileprivate struct Secrets {
    var one: UInt
    var two: UInt
    var three: UInt
    var four: UInt
    
    init(from settings: [String: Any]) {
        let one = settings[AdjustConstants.Keys.secretInfoOne] as? Int ?? 0
        let two = settings[AdjustConstants.Keys.secretInfoTwo] as? Int ?? 0
        let three = settings[AdjustConstants.Keys.secretInfoThree] as? Int ?? 0
        let four = settings[AdjustConstants.Keys.secretInfoFour] as? Int ?? 0
        self.one = UInt(one)
        self.two = UInt(two)
        self.three = UInt(three)
        self.four = UInt(four)
    }
}

fileprivate extension ADJLogLevel {
    init(from logLevel: String?) {
        guard let logLevel = logLevel else {
            self = ADJLogLevelSuppress
            return
        }
        switch logLevel {
        case "verbose":
            self = ADJLogLevelVerbose
        case "debug":
            self = ADJLogLevelDebug
        case "info":
            self = ADJLogLevelInfo
        case "warn":
            self = ADJLogLevelWarn
        case "error":
            self = ADJLogLevelError
        case "assert":
            self = ADJLogLevelAssert
        default:
            self = ADJLogLevelSuppress
        }
    }
}
