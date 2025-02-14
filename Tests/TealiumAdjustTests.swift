//
//  TealiumAdjustTests.swift
//  TealiumAdjustTests
//
//  Created by Christina S on 2/10/21.
//

import XCTest
@testable import TealiumAdjust
#if canImport(Adjust)
@testable import Adjust
#else
@testable import AdjustSdk
#endif

class TealiumAdjustTests: XCTestCase {

    var adjInstance = MockAdjustInstance()
    var adjustRemoteCommand: AdjustRemoteCommand!
    
    override func setUp() {
        adjustRemoteCommand = AdjustRemoteCommand(adjustInstance: adjInstance)
    }

    func testInitializeWithConfig_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "sandbox": true])
        XCTAssertEqual(adjInstance.initializeWithAdjustConfigCallCount, 1)
    }
    
    func testInitializeWithConfig_IsNotCalled_WithoutApiToken() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize"])
        XCTAssertEqual(adjInstance.initializeWithAdjustConfigCallCount, 0)
    }
    
    func testInitialize_SetsVariablesOnConfigToDefault_WhenNotInSettings() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "sandbox": true])
        
        // Bug in Adjust SDK: XCTAssertEqual(adjInstance.adjConfig!.logLevel, ADJLogLevelSuppress)
        XCTAssertTrue(adjInstance.adjConfig!.isAdServicesEnabled)
        XCTAssertTrue(adjInstance.adjConfig!.isIdfaReadingEnabled)
        XCTAssertTrue(adjInstance.adjConfig!.isSkanAttributionEnabled)
    }
    
    func testInitialize_SetsStandardExpectedVariablesOnConfig_WhenInSettings() {
        let settings: [String: Any] = [AdjustConstants.Keys.defaultTracker: "testDefaultTracker",
                                       AdjustConstants.Keys.externalDeviceId: "testDeviceId",
                                       AdjustConstants.Keys.eventBufferingEnabled: true,
                                       AdjustConstants.Keys.sendInBackground: true,
                                       AdjustConstants.Keys.allowAdServicesInfoReading: true,
                                       AdjustConstants.Keys.allowIdfaReading: true,
                                       AdjustConstants.Keys.urlStrategy: "DataResidencyEU",
                                       AdjustConstants.Keys.deduplicationIdMaxSize: 15]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "sandbox": true,
                                                        "settings": settings])
        
        XCTAssertEqual(adjInstance.adjConfig!.defaultTracker, "testDefaultTracker")
        XCTAssertEqual(adjInstance.adjConfig!.externalDeviceId, "testDeviceId")
        XCTAssertTrue(adjInstance.adjConfig!.isSendingInBackgroundEnabled)
        XCTAssertTrue(adjInstance.adjConfig!.isAdServicesEnabled)
        XCTAssertTrue(adjInstance.adjConfig!.isIdfaReadingEnabled)
        XCTAssertEqual(adjInstance.adjConfig!.urlStrategyDomains as? [String], ["eu.adjust.com"])
        XCTAssertTrue(adjInstance.adjConfig!.useSubdomains)
        XCTAssertTrue(adjInstance.adjConfig!.isDataResidency)
        XCTAssertEqual(adjInstance.adjConfig!.eventDeduplicationIdsMaxSize, 15)
    }

    func testInitialize_SetsCustomUrlStrategy_WhenInSettings() {
        let settings: [String: Any] = [
            AdjustConstants.Keys.urlStrategyDomains: ["customDomain.com"],
            AdjustConstants.Keys.urlStrategyUseSubdomains: true,
            AdjustConstants.Keys.urlStrategyIsResidency: true,
        ]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "sandbox": true,
                                                        "settings": settings])
        
        XCTAssertEqual(adjInstance.adjConfig!.urlStrategyDomains as? [String], ["customDomain.com"])
        XCTAssertTrue(adjInstance.adjConfig!.useSubdomains)
        XCTAssertTrue(adjInstance.adjConfig!.isDataResidency)
    }
    
    func testInitialize_SetsLogLevel() {
        let settings = [AdjustConstants.Keys.logLevel: "assert"]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "settings": settings])
        
        // Bug in Adjust SDK: XCTAssertEqual(adjInstance.adjConfig!.logLevel, ADJLogLevelAssert)
    }
    
    func testInitialize_SetsDelegate() {
        let mockDelegate = MockAdjustDelegateClass()
        adjustRemoteCommand.adjustDelegate = mockDelegate
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken"])
        XCTAssertNotNil(adjInstance.adjConfig!.delegate)
    }
    
    func testInitialize_SetsSKAdNetworkHandling() {
        let settings = [AdjustConstants.Keys.isSKAdNetworkHandlingActive: 1]
        
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "initialize",
                                                        "api_token": "testApiToken",
                                                        "settings": settings])
        
        XCTAssertTrue(adjInstance.adjConfig!.isSkanAttributionEnabled)
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

    func testSendEvent_addsTransactionId_and_DeduplicationId_for_orderId() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackevent",
                                                        "event_token": "abc123",
                                                        "order_id": "123"])
        XCTAssertEqual(adjInstance.sendEventCallCount, 1)
        XCTAssertEqual(adjInstance.adjEvent?.transactionId, "123")
        XCTAssertEqual(adjInstance.adjEvent?.deduplicationId, "123")
    }

    func testSendEvent_deduplication_id_has_priority_over_orderId() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackevent",
                                                        "event_token": "abc123",
                                                        "deduplication_id": "456",
                                                        "order_id": "123"])
        XCTAssertEqual(adjInstance.sendEventCallCount, 1)
        XCTAssertEqual(adjInstance.adjEvent?.transactionId, "123")
        XCTAssertEqual(adjInstance.adjEvent?.deduplicationId, "456")
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
                                                        "order_id": "ord123"])
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
    
    func testTrackSubscription_IsNotCalled_WhenNoData() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription"])
        XCTAssertEqual(adjInstance.trackSubscriptionCallCount, 0)
    }
    
    func testTrackSubscription_DefinesEventWithVariables() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "tracksubscription",
                                                        "event_token": "abc123",
                                                        "revenue": 24.33,
                                                        "currency": "USD",
                                                        "order_id": "ord123",
                                                        "purchase_time": 1415639000,
                                                        "sales_region": "US",
                                                        "callback": ["foo": "bar"],
                                                        "partner": ["fizz": "buzz"]])
        XCTAssertEqual(adjInstance.adjSubscription?.price, 24.33)
        XCTAssertEqual(adjInstance.adjSubscription?.currency, "USD")
        XCTAssertEqual(adjInstance.adjSubscription?.transactionId, "ord123")
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
    
    func testTrackAdRevenue_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackadrevenue",
                                                        "ad_revenue_source": "testSource"])
        XCTAssertEqual(adjInstance.trackAdRevenueCallCount, 1)
    }
    
    func testTrackAdRevenue_IsNotCalled_WhenNoSource() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackadrevenue"])
        XCTAssertEqual(adjInstance.trackAdRevenueCallCount, 0)
    }

    func testTrackAdRevenue_addsPayload() {
        adjustRemoteCommand.processRemoteCommand(with: [
            "command_name": "trackadrevenue",
            "ad_revenue_source": "testSource",
            "ad_revenue_payload": [
                "impressions_count": 3,
                "amount": 24,
                "currency": "testCurrency",
                "network": "testNetwork",
                "placement": "testPlacement",
                "unit": "testAdUnit",
                "callback": [
                    "key_callback1": "value1",
                    "key_callback2": "value2"
                ],
                "partner": [
                    "key_parameter1": "value1",
                    "key_parameter2": "value2"
                ]
            ]
        ])
        XCTAssertEqual(adjInstance.adRevenue?.adImpressionsCount, 3)
        XCTAssertEqual(adjInstance.adRevenue?.source, "testSource")
        XCTAssertEqual(adjInstance.adRevenue?.revenue, 24)
        XCTAssertEqual(adjInstance.adRevenue?.currency, "testCurrency")
        XCTAssertEqual(adjInstance.adRevenue?.adRevenueNetwork, "testNetwork")
        XCTAssertEqual(adjInstance.adRevenue?.adRevenuePlacement, "testPlacement")
        XCTAssertEqual(adjInstance.adRevenue?.adRevenueUnit, "testAdUnit")
        XCTAssertEqual(adjInstance.adRevenue?.callbackParameters as? [String: String], [
            "key_callback1": "value1",
            "key_callback2": "value2"
        ])
        XCTAssertEqual(adjInstance.adRevenue?.partnerParameters as? [String: String], [
            "key_parameter1": "value1",
            "key_parameter2": "value2"
        ])
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
    
    func testSetThirdPartySharing_IsNotCalled_WhenNoEnabledFlagAndNoOptions() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setthirdpartysharing"])
        XCTAssertEqual(adjInstance.trackThirdPartySharingCallCount, 0)
    }
    
    func testSetThirdPartySharing_IsCalled_WhenOnlyEnabledFlag() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setthirdpartysharing",
                                                        "enabled": true])
        XCTAssertEqual(adjInstance.trackThirdPartySharingCallCount, 1)
    }
    
    func testSetThirdPartySharing_IsCalled_WhenOnlyOptions() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "setthirdpartysharing",
                                                        "third_party_sharing_options": [
                                                            "partner" : [
                                                                "option": "value"
                                                            ]
                                                        ]])
        XCTAssertEqual(adjInstance.trackThirdPartySharingCallCount, 1)
    }
    
    func testTrackMeasurementConsent_IsCalled() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackmeasurementconsent",
                                                        "measurement_consent": true])
        XCTAssertEqual(adjInstance.trackMeasurementConsentCallCount, 1)
    }
    
    func testTrackMeasurementConsent_IsNotCalled_WhenNoParameters() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "trackmeasurementconsent"])
        XCTAssertEqual(adjInstance.trackMeasurementConsentCallCount, 0)
    }
    
    func testAddGlobalCallbackParams_IsCalled_With_SessionCallback() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessioncallbackparams",
                                                        "session_callback": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addGlobalCallbackParamsCallCount, 1)
    }

    func testAddGlobalCallbackParams_IsCalled_With_GlobalCallback() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addglobalcallbackparams",
                                                        "global_callback": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addGlobalCallbackParamsCallCount, 1)
    }

    func testAddGlobalCallbackParams_IsNotCalled_WhenNoParameters() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessioncallbackparams"])
        XCTAssertEqual(adjInstance.addGlobalCallbackParamsCallCount, 0)
    }
    
    func testRemoveGlobalCallbackParams_IsCalled_With_RemoveSessionCallback() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessioncallbackparams",
                                                        "remove_session_callback_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeGlobalCallbackParamsCallCount, 1)
    }
    
    func testRemoveGlobalCallbackParams_IsCalled_With_RemoveGlobalCallback() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removeglobalcallbackparams",
                                                        "remove_global_callback_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeGlobalCallbackParamsCallCount, 1)
    }
    
    func testRemoveGlobalCallbackParams_IsNotCalled_WhenNoParameters() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessioncallbackparams"])
        XCTAssertEqual(adjInstance.removeGlobalCallbackParamsCallCount, 0)
    }
    
    func testResetGlobalCallbackParams_IsCalled_With_SessionCommand() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetsessioncallbackparams"])
        XCTAssertEqual(adjInstance.resetGlobalCallbackParamsCallCount, 1)
    }
    
    func testResetGlobalCallbackParams_IsCalled_With_GlobalCommand() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetglobalcallbackparams"])
        XCTAssertEqual(adjInstance.resetGlobalCallbackParamsCallCount, 1)
    }
    
    func testAddGlobalPartnerParams_IsCalled_With_SessionPartner() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessionpartnerparams",
                                                        "session_partner": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addGlobalPartnerParamsCallCount, 1)
    }
    
    func testAddGlobalPartnerParams_IsCalled_With_GlobalPartner() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addglobalpartnerparams",
                                                        "global_partner": ["fin": "bin"]])
        XCTAssertEqual(adjInstance.addGlobalPartnerParamsCallCount, 1)
    }
    
    func testAddGlobalPartnerParams_IsNotCalled_WhenNoParameters() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "addsessionpartnerparams"])
        XCTAssertEqual(adjInstance.addGlobalPartnerParamsCallCount, 0)
    }
    
    func testRemoveGlobalPartnerParams_IsCalled_With_RemoveSessionPartner() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessionpartnerparams",
                                                        "remove_session_partner_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeGlobalPartnerParamsCallCount, 1)
    }
    
    func testRemoveGlobalPartnerParams_IsCalled_With_RemoveGlobalPartner() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removeglobalpartnerparams",
                                                        "remove_global_partner_params": ["fin"]])
        XCTAssertEqual(adjInstance.removeGlobalPartnerParamsCallCount, 1)
    }
    
    func testRemoveGlobalPartnerParams_IsNotCalled_WhenNoParameters() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "removesessionpartnerparams"])
        XCTAssertEqual(adjInstance.removeGlobalPartnerParamsCallCount, 0)
    }
    
    func testResetGlobalPartnerParams_IsCalled_With_SessionCommand() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetsessionpartnerparams"])
        XCTAssertEqual(adjInstance.resetGlobalPartnerParamsCallCount, 1)
    }
    
    func testResetGlobalPartnerParams_IsCalled_With_GlobalCommand() {
        adjustRemoteCommand.processRemoteCommand(with: ["command_name": "resetglobalpartnerparams"])
        XCTAssertEqual(adjInstance.resetGlobalPartnerParamsCallCount, 1)
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
