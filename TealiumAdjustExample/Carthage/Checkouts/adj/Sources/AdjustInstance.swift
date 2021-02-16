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
    func trackSubscription(_ subscription: ADJSubscription)
    func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void)
    func updateConversionValue(_ value: Int)
    func appWillOpen(_ url: URL)
    func trackAdRevenue(_ source: String, payload: [String: Any])
    func setPushToken(_ token: String)
    func setEnabled(_ enabled: Bool)
    func setOfflineMode(enabled: Bool)
    func gdprForgetMe()
    func trackThirdPartySharing(enabled: Bool)
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
        Adjust.appDidLaunch(config)
        initialized = true
    }
    
    public func sendEvent(_ event: ADJEvent) {
        Adjust.trackEvent(event)
    }
    
    public func trackSubscription(_ subscription: ADJSubscription) {
        Adjust.trackSubscription(subscription)
    }
    
    public func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void) {
        Adjust.requestTrackingAuthorization { status in
            completion(status)
        }
    }
    
    public func updateConversionValue(_ value: Int) {
        Adjust.updateConversionValue(value)
    }
    
    public func appWillOpen(_ url: URL) {
        Adjust.appWillOpen(url)
    }
    
    public func trackAdRevenue(_ source: String, payload: [String : Any]) {
        guard let payload = try? JSONSerialization.data(withJSONObject:payload) else {
            return
        }
        Adjust.trackAdRevenue(source, payload: payload)
    }
    
    public func setPushToken(_ token: String) {
        Adjust.setPushToken(token)
    }
    
    public func setEnabled(_ enabled: Bool) {
        Adjust.setEnabled(enabled)
    }
    
    public func setOfflineMode(enabled: Bool) {
        Adjust.setOfflineMode(enabled)
    }
    
    public func gdprForgetMe() {
        Adjust.gdprForgetMe()
    }
    
    public func trackThirdPartySharing(enabled: Bool) {
        guard let adjThirdPartySharing = ADJThirdPartySharing(isEnabledNumberBool: enabled ? 1 : 0) else {
            return
        }
        Adjust.trackThirdPartySharing(adjThirdPartySharing)
    }
    
    public func trackMeasurementConsent(consented: Bool) {
        Adjust.trackMeasurementConsent(consented)
    }
    
    public func addSessionCallbackParams(_ params: [String : String]) {
        params.forEach {
            Adjust.addSessionCallbackParameter($0.key, value: $0.value)
        }
    }
    
    public func removeSessionCallbackParams(_ paramNames: [String]) {
        paramNames.forEach {
            Adjust.removeSessionCallbackParameter($0)
        }
    }
    
    public func resetSessionCallbackParams() {
        Adjust.resetSessionCallbackParameters()
    }
    
    public func addSessionPartnerParams(_ params: [String : String]) {
        params.forEach {
            Adjust.addSessionPartnerParameter($0.key, value: $0.value)
        }
    }
    
    public func removeSessionPartnerParams(_ paramNames: [String]) {
        paramNames.forEach {
            Adjust.removeSessionPartnerParameter($0)
        }
    }
    
    public func resetSessionPartnerParams() {
        Adjust.resetSessionPartnerParameters()
    }
    
}


