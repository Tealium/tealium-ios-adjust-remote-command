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

@available(iOS 14.0, *)
private let logger = Logger()

public class AdjustRemoteCommand: RemoteCommand {
    
    public override var version: String {
        return AdjustConstants.version
    }
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
                let orderId = payload[AdjustConstants.Keys.orderId] as? String
                let deduplicationId = payload[AdjustConstants.Keys.deduplicationId] as? String
                let callbackId = payload[AdjustConstants.Keys.callbackId] as? String
                let callbackParams = payload[AdjustConstants.Keys.callbackParameters] as? [String: String]
                let partnerParams = payload[AdjustConstants.Keys.partnerParameters] as? [String: String]
                
                sendEvent(eventToken,
                          orderId: orderId,
                          deduplicationId: deduplicationId ?? orderId,
                          revenue: revenue,
                          currency: currency,
                          callbackParams: callbackParams,
                          partnerParams: partnerParams,
                          callbackId: callbackId)
            case .trackSubscription:
                guard let price = payload[AdjustConstants.Keys.revenue] as? Double,
                      let currency = payload[AdjustConstants.Keys.currency] as? String,
                      let transactionId = payload[AdjustConstants.Keys.orderId] as? String else {
                    log("revenue, currency, and order_id required")
                    return
                }
                let salesRegion = payload[AdjustConstants.Keys.salesRegion] as? String
                let purchaseTime = payload[AdjustConstants.Keys.purchaseTime] as? Double ?? 0.0
                let callbackParams = payload[AdjustConstants.Keys.callbackParameters] as? [String: String]
                let partnerParams = payload[AdjustConstants.Keys.partnerParameters] as? [String: String]
                
                trackSubscription(price: price,
                                  currency: currency,
                                  transactionId: transactionId,
                                  transactionDate: Date(timeIntervalSince1970: purchaseTime),
                                  salesRegion: salesRegion,
                                  callbackParams: callbackParams,
                                  partnerParams: partnerParams)
            case .updateConversionValue:
                guard let conversionValue = payload[AdjustConstants.Keys.conversionValue] as? Int else {
                    log("\(AdjustConstants.Keys.conversionValue) required")
                    return
                }
                adjustInstance.updateConversionValue(conversionValue,
                                                     coarseValue: payload[AdjustConstants.Keys.coarseValue] as? String,
                                                     lockWindow: payload[AdjustConstants.Keys.lockWindow] as? Bool)
            case .appWillOpenUrl:
                guard let urlString = payload[AdjustConstants.Keys.deeplinkOpenUrl] as? String,
                      let url = URL(string: urlString) else {
                    log("\(AdjustConstants.Keys.deeplinkOpenUrl) required")
                    return
                }
                adjustInstance.appWillOpen(url)
            case .trackAdRevenue:
                guard let source = payload[AdjustConstants.Keys.adRevenueSource] as? String,
                      let adRevenue = ADJAdRevenue(source: source) else {
                    log("\(AdjustConstants.Keys.adRevenueSource) required")
                    return
                }
                if let adRevenuePayload = payload[AdjustConstants.Keys.adRevenuePayload] as? [String: Any] {
                    setPayload(adRevenuePayload, to: adRevenue)
                }
                adjustInstance.trackAdRevenue(adRevenue)
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
                let enabled = payload[AdjustConstants.Keys.enabled] as? Bool
                let granularOptions = payload[AdjustConstants.Keys.thirdPartySharingOptions] as? [String: [String: String]]
                guard enabled != nil || granularOptions != nil else {
                    log("\(AdjustConstants.Keys.enabled) or \(AdjustConstants.Keys.thirdPartySharingOptions) required")
                    return
                }
                adjustInstance.trackThirdPartySharing(enabled: enabled, options: granularOptions)
            case .trackMeasurementConsent:
                guard let consented = payload[AdjustConstants.Keys.measurementConsent] as? Bool else {
                    log("\(AdjustConstants.Keys.measurementConsent) required")
                    return
                }
                adjustInstance.trackMeasurementConsent(consented: consented)
            case .addSessionCallbackParams, .addGlobalCallbackParams:
                guard let callbackParams = (payload[AdjustConstants.Keys.globalCallbackParameters] ?? payload[AdjustConstants.Keys.sessionCallbackParameters]) as? [String: String] else {
                    log("\(AdjustConstants.Keys.globalCallbackParameters) or \(AdjustConstants.Keys.sessionCallbackParameters) required")
                    return
                }
                adjustInstance.addGlobalCallbackParams(callbackParams)
            case .removeSessionCallbackParams, .removeGlobalCallbackParams:
                guard let paramNames = (payload[AdjustConstants.Keys.removeGlobalCallbackParameters] ??
                                        payload[AdjustConstants.Keys.removeSessionCallbackParameters]) as? [String] else {
                    log("\(AdjustConstants.Keys.removeGlobalCallbackParameters) or \(AdjustConstants.Keys.removeSessionCallbackParameters) required")
                    return
                }
                adjustInstance.removeGlobalCallbackParams(paramNames)
            case .resetSessionCallbackParams, .resetGlobalCallbackParams:
                adjustInstance.resetGlobalCallbackParams()
            case .addSessionPartnerParams, .addGlobalPartnerParams:
                guard let partnerParams = (payload[AdjustConstants.Keys.globalPartnerParameters] ??
                                           payload[AdjustConstants.Keys.sessionPartnerParameters]) as? [String: String] else {
                    log("\(AdjustConstants.Keys.globalPartnerParameters) or \(AdjustConstants.Keys.sessionPartnerParameters) required")
                    return
                }
                adjustInstance.addGlobalPartnerParams(partnerParams)
            case .removeSessionPartnerParams, .removeGlobalPartnerParams:
                guard let paramNames = (payload[AdjustConstants.Keys.removeGlobalPartnerParameters] ??
                                        payload[AdjustConstants.Keys.removeSessionPartnerParameters]) as? [String] else {
                    log("\(AdjustConstants.Keys.removeGlobalPartnerParameters) or \(AdjustConstants.Keys.removeSessionPartnerParameters) required")
                    return
                }
                adjustInstance.removeGlobalPartnerParams(paramNames)
            case .resetSessionPartnerParams, .resetGlobalPartnerParams:
                adjustInstance.resetGlobalPartnerParams()
            case .none:
                break
            }
        }
    }

    func setPayload(_ payload: [String : Any], to adRevenue: ADJAdRevenue) {
        if let unit = payload[AdjustConstants.Keys.adRevenueUnit] as? String {
            adRevenue.setAdRevenueUnit(unit)
        }
        if let network = payload[AdjustConstants.Keys.adRevenueNetwork] as? String {
            adRevenue.setAdRevenueNetwork(network)
        }
        if let revenueAmount = payload[AdjustConstants.Keys.adRevenueAmount] as? NSNumber,
            let currency = payload[AdjustConstants.Keys.adRevenueCurrency] as? String {
            adRevenue.setRevenue(revenueAmount.doubleValue, currency: currency)
        }
        if let placement = payload[AdjustConstants.Keys.adRevenuePlacement] as? String {
            adRevenue.setAdRevenuePlacement(placement)
        }
        if let impressionCount = payload[AdjustConstants.Keys.adRevenueImpressionsCount] as? NSNumber {
            adRevenue.setAdImpressionsCount(impressionCount.int32Value)
        }
        if let callbackParameters = payload[AdjustConstants.Keys.callbackParameters] as? [String: String] {
            for parameter in callbackParameters {
                adRevenue.addCallbackParameter(parameter.key, value: parameter.value)
            }
        }
        if let partnerParameters = payload[AdjustConstants.Keys.partnerParameters] as? [String: String] {
            for parameter in partnerParameters {
                adRevenue.addPartnerParameter(parameter.key, value: parameter.value)
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
        if let defaultTracker = settings[AdjustConstants.Keys.defaultTracker] as? String {
            config.defaultTracker = defaultTracker
        }
        if let externalDeviceId = settings[AdjustConstants.Keys.externalDeviceId] as? String {
            config.externalDeviceId = externalDeviceId
        }
        if let sendInBackground = settings[AdjustConstants.Keys.sendInBackground] as? Bool, sendInBackground {
            config.enableSendingInBackground()
        }
        if let strategyKey = settings[AdjustConstants.Keys.urlStrategy] as? String,
           let strategy = UrlStrategy.defaultStrategies[strategyKey] {
            config.setUrlStrategy(strategy.domains, useSubdomains: strategy.useSubdomains, isDataResidency: strategy.isDataResidency)
        } else if let domains = settings[AdjustConstants.Keys.urlStrategyDomains] as? [String],
                  let useSubdomains = settings[AdjustConstants.Keys.urlStrategyUseSubdomains] as? Bool,
                  let isDataResidency = settings[AdjustConstants.Keys.urlStrategyIsResidency] as? Bool {
            config.setUrlStrategy(domains, useSubdomains: useSubdomains, isDataResidency: isDataResidency)
        }
        if let allowAdServicesInfoReading = settings[AdjustConstants.Keys.allowAdServicesInfoReading] as? Bool, !allowAdServicesInfoReading {
            config.disableAdServices()
        }
        if let allowIdfaReading = settings[AdjustConstants.Keys.allowIdfaReading] as? Bool, !allowIdfaReading {
            config.disableIdfaReading()
        }
        if let isSKAdNetworkHandlingActive = settings[AdjustConstants.Keys.isSKAdNetworkHandlingActive] as? Bool, !isSKAdNetworkHandlingActive {
            config.disableSkanAttribution()
        }
        if let deduplicationIdsMaxSize = settings[AdjustConstants.Keys.deduplicationIdMaxSize] as? Int {
            config.eventDeduplicationIdsMaxSize = deduplicationIdsMaxSize
        }
        adjustInstance?.initialize(with: config)
    }
    
    public func sendEvent(_ token: String,
                          orderId: String?,
                          deduplicationId: String?,
                          revenue: Double?,
                          currency: String?,
                          callbackParams: [String : String]?,
                          partnerParams: [String : String]?,
                          callbackId: String?) {
        guard let event = ADJEvent(eventToken: token) else {
            return
        }
        if let transactionId = orderId {
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
        if let deduplicationId {
            event.setDeduplicationId(deduplicationId)
        }
        adjustInstance?.sendEvent(event)
    }
    
    public func trackSubscription(price: Double,
                                  currency: String,
                                  transactionId: String,
                                  transactionDate: Date?,
                                  salesRegion: String?,
                                  callbackParams: [String : String]?,
                                  partnerParams: [String : String]?) {
        guard let subscription = ADJAppStoreSubscription(price: NSDecimalNumber(value: price),
                                                         currency: currency,
                                                         transactionId: transactionId) else {
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

    private var logLevel: TealiumLogLevel {
        guard let tealium = TealiumInstanceManager.shared.tealiumInstances.first?.value,
              let environment = tealium.dataLayer.all[TealiumDataKey.environment] as? String else {
            return .error
        }
       return environment == "prod" ? TealiumLogLevel(from: "error") : TealiumLogLevel(from: "info")
    }

    private var logType: OSLogType? {
        switch loggerLevel {
        case .debug:
                .debug
        case .error:
                .error
        case .info:
                .info
        case .fault:
                .fault
        default:
            nil
        }
    }
    private func log(_ message: String) {
        guard let type = logType else {
            return
        }
        if #available(iOS 14.0, *) {
            logger.log(level: type,
                         "\(AdjustConstants.description, privacy: .public): \(message, privacy: .public)")
        } else {
            os_log("%{public}@",
                   type: type,
                   "\(AdjustConstants.description): \(message)")
        }
    }
    
}
fileprivate extension ADJLogLevel {
    init(from logLevel: String?) {
        guard let logLevel = logLevel else {
            self = ADJLogLevel.suppress
            return
        }
        switch logLevel {
        case "verbose":
            self = ADJLogLevel.verbose
        case "debug":
            self = ADJLogLevel.debug
        case "info":
            self = ADJLogLevel.info
        case "warn":
            self = ADJLogLevel.warn
        case "error":
            self = ADJLogLevel.error
        case "assert":
            self = ADJLogLevel.assert
        default:
            self = ADJLogLevel.suppress
        }
    }
}

struct UrlStrategy {
    
    static let defaultStrategies: [String: Self] = [
        "DataResidencyEU": UrlStrategy(domains: ["eu.adjust.com"],
                                       useSubdomains: true,
                                       isDataResidency: true),
        "DataResidencyTR": UrlStrategy(domains: ["tr.adjust.com"],
                                       useSubdomains: true,
                                       isDataResidency: true),
        "ADJDataResidencyUS": UrlStrategy(domains: ["us.adjust.com"],
                                          useSubdomains: true,
                                          isDataResidency: true),
        "UrlStrategyChina": UrlStrategy(domains: ["adjust.world", "adjust.com"],
                                        useSubdomains: true,
                                        isDataResidency: false),
        "UrlStrategyCn": UrlStrategy(domains: ["adjust.cn", "adjust.com"],
                                     useSubdomains: true,
                                     isDataResidency: false),
        "UrlStrategyCnOnly": UrlStrategy(domains: ["adjust.cn"],
                                         useSubdomains: true,
                                         isDataResidency: false),
        "UrlStrategyIndia": UrlStrategy(domains: ["adjust.net.in", "adjust.com"],
                                        useSubdomains: true,
                                        isDataResidency: false)
    ]
    let domains: [String]
    let useSubdomains: Bool
    let isDataResidency: Bool
}
