//
//  TealiumHelper.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import Foundation
import TealiumCore
import TealiumCollect
import TealiumLifecycle
import TealiumRemoteCommands
import Adjust
import TealiumAdjust

enum TealiumConfiguration {
    static let account = "tealiummobile"
    static let profile = "firebase-tag"
    static let environment = "dev"
}

class TealiumHelper {

    static let shared = TealiumHelper()

    let config = TealiumConfig(account: TealiumConfiguration.account,
        profile: TealiumConfiguration.profile,
        environment: TealiumConfiguration.environment)

    var tealium: Tealium?
    
    // JSON Remote Command
    let firebaseRemoteCommand = AdjustRemoteCommand(type: .remote(url: "https://tags.tiqcdn.com/dle/tealiummobile/demo/firebase.json"))

    private init() {
        config.shouldUseRemotePublishSettings = false
        config.batchingEnabled = false
        config.logLevel = .info
        config.collectors = [Collectors.Lifecycle]
        config.dispatchers = [Dispatchers.Collect, Dispatchers.RemoteCommands]
        
        config.addRemoteCommand(firebaseRemoteCommand)
        
        tealium = Tealium(config: config)
    }


    public func start() {
        _ = TealiumHelper.shared
    }

    class func trackView(title: String, data: [String: Any]?) {
        let tealiumView = TealiumView(title, dataLayer: data)
        TealiumHelper.shared.tealium?.track(tealiumView)
    }

    class func trackEvent(title: String, data: [String: Any]?) {
        let tealiumEvent = TealiumEvent(title, dataLayer: data)
        TealiumHelper.shared.tealium?.track(tealiumEvent)
    }

}
