//
//  Double+Round.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import Foundation

extension Double {
    var round: Double {
        let multiplier = pow(10, Double(2))
        return Darwin.round(self * multiplier) / multiplier
    }
}
