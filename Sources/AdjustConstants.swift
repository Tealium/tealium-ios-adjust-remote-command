//
//  AdjustConstants.swift
//  TealiumAdjust
//
//  Created by Christina S on 2/10/21.
//

import Foundation

public enum AdjustConstants {
    
    static let commandName = "command_name"
    static let separator: Character = ","
    static let commandId = "adjust"
    static let description = "Adjust Remote Command"
    
    enum Commands: String {
        case initialize
        case trackEvent = "trackevent"
        case trackSubscription = "tracksubscription"
        case updateConversionValue = "updateconversionvalue"
        case appWillOpenUrl = "appwillopenurl"
        case trackAdRevenue = "trackadrevenue"
        case setPushToken = "setpushtoken"
        case setEnabled = "setenabled"
        case setOfflineMode = "setofflinemode"
        case gdprForgetMe = "gdprforgetme"
        case setThirdPartySharing = "setthirdpartysharing"
        case trackMeasurementConsent = "trackmeasurementconsent"
        case addSessionCallbackParams = "addsessioncallbackparams"
        case removeSessionCallbackParams = "removesessioncallbackparams"
        case resetSessionCallbackParams = "resetsessioncallbackparams"
        case addSessionPartnerParams = "addsessionpartnerparams"
        case removeSessionPartnerParams = "removesessionpartnerparams"
        case resetSessionPartnerParams = "resetsessionpartnerparams"
    }

    enum Keys {
        static let apiToken = "api_token"
        static let sandbox = "sandbox"
        static let settings = "settings"
        static let secretId = "app_secret"
        static let secretInfoOne = "app_secret_info_1"
        static let secretInfoTwo = "app_secret_info_2"
        static let secretInfoThree = "app_secret_info_3"
        static let secretInfoFour = "app_secret_info_4"
        static let logLevel = "log_level"
        static let delayStart = "delay_start"
        static let allowiAdInfoReading = "allow_iad"
        static let allowAdServicesInfoReading = "allow_ad_services"
        static let allowIdfaReading = "allow_idfa"
        static let isSKAdNetworkHandlingActive = "sk_ad_network_active"
        static let defaultTracker = "default_tracker"
        static let externalDeviceId = "external_device_id"
        static let eventBufferingEnabled = "event_buffering_enabled"
        static let sendInBackground = "send_in_background"
        static let conversionValue = "conversion_value"
        static let deeplinkOpenUrl = "deeplink_open_url"
        static let enabled = "enabled"
        static let pushToken = "push_token"
        static let measurementConsent = "measurement_consent"
        static let eventToken = "event_token"
        static let revenue = "revenue"
        static let currency = "currency"
        static let orderId = "order_id"
        static let receipt = "receipt"
        static let salesRegion = "sales_region"
        static let purchaseTime = "purchase_time"
        static let callbackId = "callback_id"
        static let callbackParameters = "callback"
        static let partnerParameters = "partner"
        static let sessionCallbackParameters = "session_callback"
        static let sessionPartnerParameters = "session_partner"
        static let removeSessionCallbackParameters = "remove_session_callback_params"
        static let removeSessionPartnerParameters = "remove_session_partner_params"
        static let adRevenueSource = "ad_revenue_source"
        static let adRevenuePayload = "ad_revenue_payload"
    }
    
}
