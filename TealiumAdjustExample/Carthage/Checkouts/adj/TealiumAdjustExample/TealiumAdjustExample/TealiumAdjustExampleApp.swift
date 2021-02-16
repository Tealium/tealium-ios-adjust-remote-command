//
//  TealiumAdjustExampleApp.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

@main
struct TealiumAdjustExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            TealiumHelper.shared.start()
            return true
    }
}
