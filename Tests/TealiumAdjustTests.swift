//
//  TealiumAdjustTests.swift
//  TealiumAdjustTests
//
//  Created by Christina S on 2/10/21.
//

import XCTest
@testable import TealiumAdjust
@testable import AdjustSdk

class TealiumAdjustTests: XCTestCase {

    var adjInstance = MockAdjustInstance()
    var adjustRemoteCommand: AdjustRemoteCommand!
    
    override func setUp() {
        adjustRemoteCommand = AdjustRemoteCommand(adjustInstance: adjInstance)
    }

    func testInitializeWithConfig_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "test_api_token",
                                                        "sandbox": true])
        XCTAssertEqual(adjInstance.initializeWithAdjustConfigCallCount, 1)
    }
    
    func testInitializeWithConfig_IsNotCalled_WithoutApiToken() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize"])
        XCTAssertEqual(adjInstance.initializeWithAdjustConfigCallCount, 0)
    }
    
    func testInitialize_SetsVariablesOnConfigToDefault_WhenNotInSettings() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "test_api_token",
                                                        "sandbox": true])
        
        // Bug in Adjust SDK: XCTAssertEqual(adjInstance.adjConfig!.logLevel, ADJLogLevelSuppress)
        XCTAssertFalse(adjInstance.adjConfig!.allowiAdInfoReading)
        XCTAssertFalse(adjInstance.adjConfig!.allowAdServicesInfoReading)
        XCTAssertFalse(adjInstance.adjConfig!.allowIdfaReading)
        XCTAssertFalse(adjInstance.adjConfig!.isSKAdNetworkHandlingActive)
    }
    
    func testInitialize_SetsStandardExpectedVariablesOnConfig_WhenInSettings() {
        let settings: [String: Any] = [AdjustConstants.Keys.delayStart: 30.0,
                                       AdjustConstants.Keys.defaultTracker: "testDefaultTracker",
                                       AdjustConstants.Keys.externalDeviceId: "testDeviceId",
                                       AdjustConstants.Keys.eventBufferingEnabled: true,
                                       AdjustConstants.Keys.sendInBackground: true,
                                       AdjustConstants.Keys.allowiAdInfoReading: true,
                                       AdjustConstants.Keys.allowAdServicesInfoReading: true,
                                       AdjustConstants.Keys.allowIdfaReading: true,
                                       AdjustConstants.Keys.urlStrategy: "url_strategy_china"]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "test_api_token",
                                                        "sandbox": true,
                                                        "settings": settings])
        
        XCTAssertEqual(adjInstance.adjConfig!.delayStart, 30.0)
        XCTAssertEqual(adjInstance.adjConfig!.defaultTracker, "testDefaultTracker")
        XCTAssertEqual(adjInstance.adjConfig!.externalDeviceId, "testDeviceId")
        XCTAssertTrue(adjInstance.adjConfig!.sendInBackground)
        XCTAssertTrue(adjInstance.adjConfig!.allowiAdInfoReading)
        XCTAssertTrue(adjInstance.adjConfig!.allowAdServicesInfoReading)
        XCTAssertTrue(adjInstance.adjConfig!.allowIdfaReading)
        XCTAssertEqual(adjInstance.adjConfig!.urlStrategy, "url_strategy_china")
    }
    
    func testInitialize_SetsLogLevel() {
        let settings = [AdjustConstants.Keys.logLevel: "assert"]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "h9a5gman7nr4",
                                                        "settings": settings])
        
        // Bug in Adjust SDK: XCTAssertEqual(adjInstance.adjConfig!.logLevel, ADJLogLevelAssert)
    }
    
    func testInitialize_SetsAppSecret() {
        let settings = [AdjustConstants.Keys.secretId: 1234,
                        AdjustConstants.Keys.secretInfoOne: 1,
                        AdjustConstants.Keys.secretInfoTwo: 2,
                        AdjustConstants.Keys.secretInfoThree: 3,
                        AdjustConstants.Keys.secretInfoFour: 4]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "test_api_token",
                                                        "settings": settings])
        
        XCTAssertEqual(adjInstance.adjConfig!.appSecret, "1234")
        XCTAssertEqual(adjInstance.adjConfig!.secretId, "1234")
    }

    
    func testInitialize_SetsDelegate() {
        let mockDelegate = MockAdjustDelegateClass()
        adjustRemoteCommand.adjustDelegate = mockDelegate
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "h9a5gman7nr4"])
        XCTAssertNotNil(adjInstance.adjConfig!.delegate)
    }
    
    func testInitialize_SetsSKAdNetworkHandling() {
        let settings = [AdjustConstants.Keys.isSKAdNetworkHandlingActive: 1]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "h9a5gman7nr4",
                                                        "settings": settings])
        
        XCTAssertTrue(adjInstance.adjConfig!.isSKAdNetworkHandlingActive)
    }
    
    func testRequestTrackingAuthorizationCalled_WhenCompletionIsSet() {
        adjustRemoteCommand.trackingAuthorizationCompletion = { _ in }
        XCTAssertEqual(adjInstance.requestTrackingAuthorizationCallCount, 1)
    }
    
    func testSendEvent_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackevent",
                                                        "event_token": "abc123"])
        XCTAssertEqual(adjInstance.sendEventCallCount, 1)
    }
    
    func testTrackEvent_IsNotCalled_WhenNoEventToken() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackevent"])
        XCTAssertEqual(adjInstance.sendEventCallCount, 0)
    }
    
    func testTrackEvent_DefinesEventWithVariables() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackevent",
                                                        "event_token": "abc123",
                                                        "revenue": 24.33,
                                                        "currency": "USD",
                                                        "order_id": "ord123",
                                                        "callback_id": "call123",
                                                        "callback": ["foo": "bar"],
                                                        "partner": ["fizz": "buzz"]])
        XCTAssertEqual(adjInstance.adjEvent?.eventToken, "abc123")
        XCTAssertEqual(adjInstance.adjEvent?.revenue, 24.33)
        XCTAssertEqual(adjInstance.adjEvent?.currency, "USD")
        XCTAssertEqual(adjInstance.adjEvent?.transactionId, "ord123")
        XCTAssertEqual(adjInstance.adjEvent?.callbackId, "call123")
        XCTAssertTrue(adjInstance.adjEvent!.callbackParameters.equal(to: ["foo": "bar"]))
        XCTAssertTrue(adjInstance.adjEvent!.partnerParameters.equal(to: ["fizz": "buzz"]))
    }
    
    func testTrackSubscription_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription",
                                                        "revenue": 24.33,
                                                        "currency": "USD",
                                                        "order_id": "ord123",
                                                        "receipt": Data()])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 1)
    }
    
    func testTrackSubscription_IsNotCalled_WhenNoRevenue() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription"])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 0)
    }
    
    func testTrackSubscription_IsNotCalled_WhenNoCurrency() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription"])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 0)
    }
    
    func testTrackSubscription_IsNotCalled_WhenNoTransactionId() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription"])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 0)
    }
    
    func testTrackSubscription_IsNotCalled_WhenNoReceipt() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription"])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 0)
    }
    
    func testTrackSubscription_DefinesEventWithVariables() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription",
                                                        "event_token": "abc123",
                                                        "revenue": 24.33,
                                                        "currency": "USD",
                                                        "order_id": "ord123",
                                                        "receipt": Data(),
                                                        "purchase_time": 1415639000,
                                                        "sales_region": "US",
                                                        "callback": ["foo": "bar"],
                                                        "partner": ["fizz": "buzz"]])
        XCTAssertEqual(adjInstance.adjSubscription?.price, 24.33)
        XCTAssertEqual(adjInstance.adjSubscription?.currency, "USD")
        XCTAssertEqual(adjInstance.adjSubscription?.transactionId, "ord123")
        XCTAssertNotNil(adjInstance.adjSubscription?.receipt)
        XCTAssertNotNil(adjInstance.adjSubscription?.transactionDate)
        XCTAssertTrue(adjInstance.adjSubscription!.callbackParameters.equal(to: ["foo": "bar"]))
        XCTAssertTrue(adjInstance.adjSubscription!.partnerParameters.equal(to: ["fizz": "buzz"]))
    }
    
    func testUpdateConversionValue_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "updateconversionvalue",
                                                        "conversion_value": 10])
        XCTAssertEqual(adjInstance.updateConversionValueCallCount, 1)
    }
    
    func testUpdateConversionValue_IsNotCalled_WhenNoValue() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "updateconversionvalue"])
        XCTAssertEqual(adjInstance.updateConversionValueCallCount, 0)
    }
    
    func testAppWillOpenUrl_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "appwillopenurl",
                                                        "deeplink_open_url": "app://helloworld"])
        XCTAssertEqual(adjInstance.appWillOpenCallCount, 1)
    }
    
    func testAppWillOpenUrl_IsNotCalled_WhenNoUrlString() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "appwillopenurl"])
        XCTAssertEqual(adjInstance.appWillOpenCallCount, 0)
    }
    
    func testAppWillOpenUrl_IsNotCalled_WhenUrlStringInvalid() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "appwillopenurl",
                                                        "deeplink_open_url": "😀"])
        XCTAssertEqual(adjInstance.appWillOpenCallCount, 0)
    }
    
    func testTrackAdRevenue_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackadrevenue",
                                                        "ad_revenue_source": "testSource",
                                                        "ad_revenue_payload": ["fan": "ban"]])
        XCTAssertEqual(adjInstance.trackAdRevenueCallCount, 1)
    }
    
    func testTrackAdRevenue_IsNotCalled_WhenNoSource() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackadrevenue",
                                                        "ad_revenue_payload": ["fan": "ban"]])
        XCTAssertEqual(adjInstance.trackAdRevenueCallCount, 0)
    }
    
    func testTrackAdRevenue_IsNotCalled_WhenNoPayload() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackadrevenue",
                                                        "ad_revenue_source": "testSource"])
        XCTAssertEqual(adjInstance.trackAdRevenueCallCount, 0)
    }
    
    func testSetPushToken_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setpushtoken",
                                                        "push_token": "testToken"])
        XCTAssertEqual(adjInstance.setPushTokenCallCount, 1)
    }
    
    func testSetPushToken_IsNotCalled_WhenNoToken() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setpushtoken"])
        XCTAssertEqual(adjInstance.setPushTokenCallCount, 0)
    }
    
    func testSetEnabled_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setenabled",
                                                        "enabled": true])
        XCTAssertEqual(adjInstance.setEnabledCallCount, 1)
    }
    
    func testSetEnabled_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setenabled"])
        XCTAssertEqual(adjInstance.setEnabledCallCount, 0)
    }
    
    func testOfflineMode_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setofflinemode",
                                                        "enabled": true])
        XCTAssertEqual(adjInstance.setOfflineModeCallCount, 1)
    }
    
    func testOfflineMode_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setofflinemode"])
        XCTAssertEqual(adjInstance.setOfflineModeCallCount, 0)
    }
    
    func testGdprForgetMe_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "gdprforgetme"])
        XCTAssertEqual(adjInstance.gdprForgetMeCallCount, 1)
    }

    func testSetThirdPartySharing_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setthirdpartysharing",
                                                        "enabled": true])
        XCTAssertEqual(adjInstance.trackThirdPartySharingCallCount, 1)
    }
    
    func testSetThirdPartySharing_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setthirdpartysharing"])
        XCTAssertEqual(adjInstance.trackThirdPartySharingCallCount, 0)
    }
    
    func testTrackMeasurementConsent_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackmeasurementconsent",
                                                        "measurement_consent": true])
        XCTAssertEqual(adjInstance.trackMeasurementConsentCallCount, 1)
    }
    
    func testTrackMeasurementConsent_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackmeasurementconsent"])
        XCTAssertEqual(adjInstance.trackMeasurementConsentCallCount, 0)
    }
    
    func testAddSessionCallbackParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessioncallbackparams",
                                                        "session_callback": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addSessionCallbackParamsCallCount, 1)
    }
    
    func testAddSessionCallbackParams_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessioncallbackparams"])
        XCTAssertEqual(adjInstance.addSessionCallbackParamsCallCount, 0)
    }
    
    func testRemoveSessionCallbackParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessioncallbackparams",
                                                        "remove_session_callback_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeSessionCallbackParamsCallCount, 1)
    }
    
    func testRemoveSessionCallbackParams_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessioncallbackparams"])
        XCTAssertEqual(adjInstance.removeSessionCallbackParamsCallCount, 0)
    }
    
    func testResetSessionCallbackParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetsessioncallbackparams"])
        XCTAssertEqual(adjInstance.resetSessionCallbackParamsCallCount, 1)
    }
    
    func testAddSessionPartnerParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessionpartnerparams",
                                                        "session_partner": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addSessionPartnerParamsCallCount, 1)
    }
    
    func testAddSessionPartnerParams_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessionpartnerparams"])
        XCTAssertEqual(adjInstance.addSessionPartnerParamsCallCount, 0)
    }
    
    func testRemoveSessionPartnerParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessionpartnerparams",
                                                        "remove_session_partner_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeSessionPartnerParamsCallCount, 1)
    }
    
    func testRemoveSessionPartnerParams_IsNotCalled_WhenNoEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessionpartnerparams"])
        XCTAssertEqual(adjInstance.removeSessionPartnerParamsCallCount, 0)
    }
    
    func testResetSessionPartnerParams_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetsessionpartnerparams"])
        XCTAssertEqual(adjInstance.resetSessionPartnerParamsCallCount, 1)
    }
    
}

fileprivate extension Dictionary where Key == AnyHashable, Value == Any {
    func equal(to dictionary: [String: Any] ) -> Bool {
        NSDictionary(dictionary: self).isEqual(to: dictionary)
    }
}

fileprivate func delay(_ completion: @escaping () -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        completion()
    }
}
