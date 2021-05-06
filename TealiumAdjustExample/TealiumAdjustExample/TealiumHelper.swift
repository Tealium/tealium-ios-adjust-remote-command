//
//  TealiumHelper.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import Foundation
import TealiumSwift
import TealiumAdjust
import AdSupport
import iAd
import Adjust

enum TealiumConfiguration {
    static let account = "tealiummobile"
    static let profile = "demo"
    static let environment = "dev"
}

class TealiumHelper: NSObject {

    static let shared = TealiumHelper()

    let config = TealiumConfig(account: TealiumConfiguration.account,
        profile: TealiumConfiguration.profile,
        environment: TealiumConfiguration.environment)

    var tealium: Tealium?
    
    // JSON Remote Command
    // let adjustRemoteCommand = AdjustRemoteCommand(type: .remote(url: "https://tags.tiqcdn.com/dle/tealiummobile/demo/adjust.json"))
    let adjustRemoteCommand = AdjustRemoteCommand(type: .local(file: "adjust"))
    
    // TiQ Remote Command
    // let adjustRemoteCommand = AdjustRemoteCommand(type: .webview)
    
    private override init() {
        super.init()
        config.shouldUseRemotePublishSettings = false
        config.batchingEnabled = false
        config.remoteAPIEnabled = true
        config.logLevel = .info
        config.collectors = [Collectors.Lifecycle, Collectors.Attribution]
        config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]
        
        // Optional: Set delegate and tracking auth callback
        adjustRemoteCommand.adjustDelegate = self
        adjustRemoteCommand.trackingAuthorizationCompletion = { status in
            switch status {
            case 0: print("ATTrackingManagerAuthorizationStatusNotDetermined")
            case 1: print("ATTrackingManagerAuthorizationStatusRestricted")
            case 2: print("ATTrackingManagerAuthorizationStatusDenied")
            case 3: print("ATTrackingManagerAuthorizationStatusAuthorized")
            default:
                break;
            }
        }

        tealium = Tealium(config: config) { _ in
            guard let remoteCommands = self.tealium?.remoteCommands else {
                return
            }
            remoteCommands.add(self.adjustRemoteCommand)
        }
    }


    public func start() {
        _ = TealiumHelper.shared
    }

    class func trackView(title: String, data: [String: Any]?) {
        let tealiumView = TealiumView(title, dataLayer: data)
        TealiumHelper.shared.tealium?.track(tealiumView)
    }

    class func trackEvent(title: String, data: [String: Any]? = nil) {
        let tealiumEvent = TealiumEvent(title, dataLayer: data)
        TealiumHelper.shared.tealium?.track(tealiumEvent)
    }

}

extension TealiumHelper: AdjustDelegate {
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        print("Attribution callback called!")
        print("Attribution: %@", attribution ?? "")
    }

    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
        print("Event success callback called!")
        print("Event success data: %@", eventSuccessResponseData ?? "")
    }

    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
        print("Event failure callback called!")
        print("Event failure data: %@", eventFailureResponseData ?? "")
    }

    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
        print("Session success callback called!")
        print("Session success data: %@", sessionSuccessResponseData ?? "")
    }

    func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?) {
        print("Session failure callback called!");
        print("Session failure data: %@", sessionFailureResponseData ?? "")
    }

    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        print("Deferred deep link callback called!")
        print("Deferred deep link URL: %@", deeplink?.absoluteString ?? "")
        return true
    }
}
