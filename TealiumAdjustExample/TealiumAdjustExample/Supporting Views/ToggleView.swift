//
//  ToggleView.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

struct ToggleView: View {
    var title: String
    @Binding var isOn: Bool
    var action: ((Bool) -> Void)?
    
    init(_ title: String,
         isOn: Binding<Bool>,
         _ action: ((Bool) -> Void)? = nil) {
        self.title = title
        self._isOn = isOn
        self.action = action
    }
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .padding(.horizontal)
            .toggleStyle(SwitchToggleStyle(tint: .tealBlue))
            .onChange(of: isOn) { value in
                if let action = action {
                    action(value)
                }
            }
    }
}

struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        ToggleView("test", isOn: .constant(true))
    }
}
