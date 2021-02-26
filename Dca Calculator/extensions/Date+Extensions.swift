//
//  Date+Extensions.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 26/02/2021.
//

import Foundation

extension Date {
    
    var MMYYFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
}
