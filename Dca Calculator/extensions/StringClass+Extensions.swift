//
//  StringClass+Extensions.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 25/02/2021.
//

import Foundation

extension String {
    
    func addBrackets() -> String {
        return "(\(self)"
    }
    
    func prefix(withText text: String) -> String {
        return text + self
    }
    
    func toDouble() -> Double? {
        return Double(self)
    }
}
