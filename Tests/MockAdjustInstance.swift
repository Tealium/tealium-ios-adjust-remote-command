//
//  MockAdjustInstance.swift
//  TealiumAdjust
//
//  Created by Christina S on 2/11/21.
//

import Foundation
@testable import TealiumAdjust
#if canImport(Adjust)
@testable import Adjust
#else
@testable import AdjustSdk
#endif


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
    var addGlobalCallbackParamsCallCount = 0
    var removeGlobalCallbackParamsCallCount = 0
    var resetGlobalCallbackParamsCallCount = 0
    var addGlobalPartnerParamsCallCount = 0
    var removeGlobalPartnerParamsCallCount = 0
    var resetGlobalPartnerParamsCallCount = 0
    
    var adjustDelegate: (AdjustDelegate & NSObjectProtocol)?
    var adjConfig: ADJConfig?
    var adjEvent: ADJEvent?
    var adjSubscription: ADJAppStoreSubscription?
    var adRevenue: ADJAdRevenue?
    
    
    func initialize(with config: ADJConfig) {
        adjConfig = config
        initializeWithAdjustConfigCallCount += 1
    }
    
    func sendEvent(_ event: ADJEvent) {
        adjEvent = event
        sendEventCallCount += 1
    }
    
    func trackSubscription(_ subscription: ADJAppStoreSubscription) {
        adjSubscription = subscription
        trackSubscriptionCallCount += 1
    }
    
    func requestTrackingAuthorization(with completion: @escaping (UInt) -> Void) {
        requestTrackingAuthorizationCallCount += 1
    }
    
    func updateConversionValue(_ value: Int, coarseValue: String?, lockWindow: Bool?) {
        updateConversionValueCallCount += 1
    }
    
    func appWillOpen(_ url: URL) {
        appWillOpenCallCount += 1
    }
    
    func trackAdRevenue(_ adRevenue: ADJAdRevenue) {
        self.adRevenue = adRevenue
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
    
    func trackThirdPartySharing(enabled: Bool?, options: [String: [String: String]]?) {
        trackThirdPartySharingCallCount += 1
    }
    
    func trackMeasurementConsent(consented: Bool) {
        trackMeasurementConsentCallCount += 1
    }
    
    func addGlobalCallbackParams(_ params: [String : String]) {
        addGlobalCallbackParamsCallCount += 1
    }
    
    func removeGlobalCallbackParams(_ paramNames: [String]) {
        removeGlobalCallbackParamsCallCount += 1
    }
    
    func resetGlobalCallbackParams() {
        resetGlobalCallbackParamsCallCount += 1
    }
    
    func addGlobalPartnerParams(_ params: [String : String]) {
        addGlobalPartnerParamsCallCount += 1
    }
    
    func removeGlobalPartnerParams(_ paramNames: [String]) {
        removeGlobalPartnerParamsCallCount += 1
    }
    
    func resetGlobalPartnerParams() {
        resetGlobalPartnerParamsCallCount += 1
    }

}
