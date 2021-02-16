//
//  EventsView.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

struct EventsView: View {
    @State private var token = ""
    var body: some View {
        VStack(spacing: 20) {
            TitleView("Events")
            CustomTextField(placeholder: "Event Token", text: $token, width: 200)
            TextButtonView(title: "Track Event") {
                TealiumHelper.trackEvent(title: "event",
                                         data: ["event_token": token])
            }
            TextButtonView(title: "Track Event w/Parameters") {
                TealiumHelper.trackEvent(title: "contact",
                                         data: ["event_token": token,
                                                "favorite_color": "Red",
                                                "num_of_pets": 3])
            }
            TextButtonView(title: "Send Push Token") {
                TealiumHelper.trackEvent(title: "received_push_token",
                                         data: ["push_token": UUID().uuidString.remove("-")])
            }
            TextButtonView(title: "Track Deeplink") {
                TealiumHelper.trackEvent(title: "track_deeplink",
                                         data: ["deeplink_url": "app://someurl?hello=world"])
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
