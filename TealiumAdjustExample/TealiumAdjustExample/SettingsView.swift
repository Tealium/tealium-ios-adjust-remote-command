//
//  SettingsView.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

struct Settings {
    var key = ""
    var value = ""
    var keysToRemove = ""
    var consented = true
    var enabled = true
    var offlineMode = true
}

struct SettingsView: View {
    @State private var settings = Settings()
    var body: some View {
        VStack {
            TitleView("Session Settings")
            ToggleView("Consent", isOn: $settings.consented) { value in
                TealiumHelper.trackEvent(title: (value ? "consent_granted" : "consent_revoked"),
                                         data: ["consent_granted": value])
            }
            ToggleView("Enabled", isOn: $settings.enabled) { value in
                TealiumHelper.trackEvent(title: "set_enabled", data: ["enabled": value])
            }
            ToggleView("Offline Mode", isOn: $settings.offlineMode) { value in
                TealiumHelper.trackEvent(title: "offline", data: ["enabled": value])
            }
            HStack {
                CustomTextField(placeholder: "Key", text: $settings.key)
                CustomTextField(placeholder: "Value", text: $settings.value)
            }
            TextButtonView(title: "Add Parameters") {
                TealiumHelper.trackEvent(title: "add_session_parameters",
                                         data: ["session_params": [settings.key: settings.value]])
            }
            CustomTextField(placeholder: "Keys (e.g. key1,key2)", text: $settings.keysToRemove, width: 200)
            TextButtonView(title: "Remove Parameters") {
                TealiumHelper.trackEvent(title: "remove_session_parameters",
                                         data: ["remove_session_params": settings.keysToRemove
                                                                            .split(separator: ",")
                                                                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }])
            }
            TextButtonView(title: "Reset Parameters") {
                TealiumHelper.trackEvent(title: "reset_session_parameters")
            }
        }.frame(width: UIScreen.main.bounds.width-20, alignment: .center)
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
