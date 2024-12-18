//
//  AdjustInstance.swift
//  TealiumAdjust
//
//  Created by Christina S on 2/10/21.
//

import Foundation
#if canImport(Adjust)
import Adjust
#else
import AdjustSdk
#endif

public protocol AdjustCommand {
    func initialize(with config: ADJConfig)
    func sendEvent(_ event: ADJEvent)
    func trackSubscription(_ subscription: ADJAppStoreSubscription)
    func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void)
    func updateConversionValue(_ value: Int, coarseValue: String?, lockWindow: Bool?)
    func appWillOpen(_ url: URL)
    func trackAdRevenue(_ adRevenue: ADJAdRevenue)
    func setPushToken(_ token: String)
    func setEnabled(_ enabled: Bool)
    func setOfflineMode(enabled: Bool)
    func gdprForgetMe()
    func trackThirdPartySharing(enabled: Bool?, options: [String: [String: String]]?)
    func trackMeasurementConsent(consented: Bool)
    func addSessionCallbackParams(_ params: [String: String])
    func removeSessionCallbackParams(_ paramNames: [String])
    func resetSessionCallbackParams()
    func addSessionPartnerParams(_ params: [String: String])
    func removeSessionPartnerParams(_ paramNames: [String])
    func resetSessionPartnerParams()
}

public class AdjustInstance: AdjustCommand {

    private var initialized = false
    
    public convenience init(with adjustConfig: ADJConfig) {
        self.init()
        self.initialize(with: adjustConfig)
    }
    
    public init() { }
    
    public func initialize(with config: ADJConfig) {
        guard !initialized else {
            return
        }
        Adjust.initSdk(config)
        initialized = true
    }
    
    public func sendEvent(_ event: ADJEvent) {
        Adjust.trackEvent(event)
    }
    
    public func trackSubscription(_ subscription: ADJAppStoreSubscription) {
        Adjust.trackAppStoreSubscription(subscription)
    }
    
    public func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void) {
        Adjust.requestAppTrackingAuthorization { status in
            completion(status)
        }
    }
    
    public func updateConversionValue(_ value: Int, coarseValue: String?, lockWindow: Bool?) {
        Adjust.updateSkanConversionValue(value, coarseValue: coarseValue, lockWindow: lockWindow.map { $0 ? 1 : 0 })
    }
    
    public func appWillOpen(_ url: URL) {
        if let deeplink = ADJDeeplink(deeplink: url) {
            Adjust.processDeeplink(deeplink)
        }
    }
    
    public func trackAdRevenue(_ adRevenue: ADJAdRevenue) {
        Adjust.trackAdRevenue(adRevenue)
    }
    
    public func setPushToken(_ token: String) {
        Adjust.setPushToken(Data(token.utf8))
    }
    
    public func setEnabled(_ enabled: Bool) {
        if enabled {
            Adjust.enable()
        } else {
            Adjust.disable()
        }
    }
    
    public func setOfflineMode(enabled: Bool) {
        if enabled {
            Adjust.switchToOfflineMode()
        } else {
            Adjust.switchBackToOnlineMode()
        }
    }
    
    public func gdprForgetMe() {
        Adjust.gdprForgetMe()
    }
    
    public func trackThirdPartySharing(enabled: Bool?, options: [String: [String: String]]?) {
        guard let adjThirdPartySharing = ADJThirdPartySharing(isEnabled: enabled.map { $0 ? 1 : 0 } ) else {
            return
        }
        
        if let options = options {
            options.forEach { (partner, partnerOpts) in
                partnerOpts.forEach { (key, value) in
                    adjThirdPartySharing.addGranularOption(partner, key: key, value: value)
                }
            }
        }
        Adjust.trackThirdPartySharing(adjThirdPartySharing)
    }
    
    public func trackMeasurementConsent(consented: Bool) {
        Adjust.trackMeasurementConsent(consented)
    }
    
    public func addSessionCallbackParams(_ params: [String : String]) {
        params.forEach {
            Adjust.addGlobalCallbackParameter($0.value, forKey: $0.key)
        }
    }
    
    public func removeSessionCallbackParams(_ paramNames: [String]) {
        paramNames.forEach {
            Adjust.removeGlobalCallbackParameter(forKey: $0)
        }
    }
    
    public func resetSessionCallbackParams() {
        Adjust.removeGlobalCallbackParameters()
    }
    
    public func addSessionPartnerParams(_ params: [String : String]) {
        params.forEach {
            Adjust.addGlobalPartnerParameter($0.value, forKey: $0.key)
        }
    }
    
    public func removeSessionPartnerParams(_ paramNames: [String]) {
        paramNames.forEach {
            Adjust.removeGlobalPartnerParameter(forKey: $0)
        }
    }
    
    public func resetSessionPartnerParams() {
        Adjust.removeGlobalPartnerParameters()
    }
}


