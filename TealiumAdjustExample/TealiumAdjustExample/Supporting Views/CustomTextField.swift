//
//  CustomTextField.swift
//  TealiumAdjustExample
//
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var width: CGFloat = 80
    var body: some View {
            HStack {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
              }
            .accentColor(.tealBlue)
            .frame(width: width, height: 15)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.tealBlue, lineWidth: 1))
    }
}
