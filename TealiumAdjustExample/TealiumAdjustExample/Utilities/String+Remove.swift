//
//  String+RemoveDashes.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import Foundation

extension String {
    func remove(_ string: String) -> String {
        self.replacingOccurrences(of: string, with: "")
    }
}

