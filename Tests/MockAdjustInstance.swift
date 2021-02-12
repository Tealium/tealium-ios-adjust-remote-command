//
//  MockAdjustInstance.swift
//  TealiumAdjust
//
//  Created by Christina S on 2/11/21.
//

import Foundation
@testable import TealiumAdjust
@testable import AdjustSdk

class MockAdjustDelegateClass: NSObject, AdjustDelegate {
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        NSLog("Attribution callback called!")
        NSLog("Attribution: %@", attribution ?? "")
    }

    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
        NSLog("Event success callback called!")
        NSLog("Event success data: %@", eventSuccessResponseData ?? "")
    }

    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
        NSLog("Event failure callback called!")
        NSLog("Event failure data: %@", eventFailureResponseData ?? "")
    }

    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
        NSLog("Session success callback called!")
        NSLog("Session success data: %@", sessionSuccessResponseData ?? "")
    }

    func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?) {
        NSLog("Session failure callback called!");
        NSLog("Session failure data: %@", sessionFailureResponseData ?? "")
    }

    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        NSLog("Deferred deep link callback called!")
        NSLog("Deferred deep link URL: %@", deeplink?.absoluteString ?? "")
        return true
    }
    
}

class MockAdjustInstance: AdjustCommand {
        
    var initializeWithAdjustConfigCallCount = 0
    var sendEventCallCount = 0
    var trackSubscriptionCallCount = 0
    var requestTrackingAuthorizationCallCount = 0
    var updateConversionValueCallCount = 0
    var appWillOpenCallCount = 0
    var trackAdRevenueCallCount = 0
    var setPushTokenCallCount = 0
    var setEnabledCallCount = 0
    var setOfflineModeCallCount = 0
    var gdprForgetMeCallCount = 0
    var trackThirdPartySharingCallCount = 0
    var trackMeasurementConsentCallCount = 0
    var addSessionCallbackParamsCallCount = 0
    var removeSessionCallbackParamsCallCount = 0
    var resetSessionCallbackParamsCallCount = 0
    var addSessionPartnerParamsCallCount = 0
    var removeSessionPartnerParamsCallCount = 0
    var resetSessionPartnerParamsCallCount = 0
    
    var adjustDelegate: (AdjustDelegate & NSObjectProtocol)?
    var adjConfig: ADJConfig?
    var adjEvent: ADJEvent?
    var adjSubscription: ADJSubscription?
    
    
    func initialize(with config: ADJConfig) {
        adjConfig = config
        initializeWithAdjustConfigCallCount += 1
    }
    
    func sendEvent(_ event: ADJEvent) {
        adjEvent = event
        sendEventCallCount += 1
    }
    
    func trackSubscription(_ subscription: ADJSubscription) {
        adjSubscription = subscription
        trackSubscriptionCallCount += 1
    }
    
    func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void) {
        requestTrackingAuthorizationCallCount += 1
    }
    
    func updateConversionValue(_ value: Int) {
        updateConversionValueCallCount += 1
    }
    
    func appWillOpen(_ url: URL) {
        appWillOpenCallCount += 1
    }
    
    func trackAdRevenue(_ source: String, payload: [String : Any]) {
        trackAdRevenueCallCount += 1
    }
    
    func setPushToken(_ token: String) {
        setPushTokenCallCount += 1
    }
    
    func setEnabled(_ enabled: Bool) {
        setEnabledCallCount += 1
    }
    
    func setOfflineMode(enabled: Bool) {
        setOfflineModeCallCount += 1
    }
    
    func gdprForgetMe() {
        gdprForgetMeCallCount += 1
    }
    
    func trackThirdPartySharing(enabled: Bool) {
        trackThirdPartySharingCallCount += 1
    }
    
    func trackMeasurementConsent(consented: Bool) {
        trackMeasurementConsentCallCount += 1
    }
    
    func addSessionCallbackParams(_ params: [String : String]) {
        addSessionCallbackParamsCallCount += 1
    }
    
    func removeSessionCallbackParams(_ paramNames: [String]) {
        removeSessionCallbackParamsCallCount += 1
    }
    
    func resetSessionCallbackParams() {
        resetSessionCallbackParamsCallCount += 1
    }
    
    func addSessionPartnerParams(_ params: [String : String]) {
        addSessionPartnerParamsCallCount += 1
    }
    
    func removeSessionPartnerParams(_ paramNames: [String]) {
        removeSessionPartnerParamsCallCount += 1
    }
    
    func resetSessionPartnerParams() {
        resetSessionPartnerParamsCallCount += 1
    }

}
