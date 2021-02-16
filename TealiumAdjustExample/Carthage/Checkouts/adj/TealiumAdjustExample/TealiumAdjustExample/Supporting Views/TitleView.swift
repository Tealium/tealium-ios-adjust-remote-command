//
//  TitleView.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

struct TitleView: View {
    var title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .padding([.bottom], 10)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView("Test Title")
    }
}
