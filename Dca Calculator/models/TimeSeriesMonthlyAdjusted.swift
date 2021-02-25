//
//  TimeSeriesMonthlyAdjusted.swift
//  Dca Calculator
//
//  Created by mohammad khair pk on 25/02/2021.
//

import Foundation

struct TimeSeriesMonthlyAdjusted: Decodable {
    
    let meta: Meta
    let timeSeries: [String: OHLC]
    
}

struct Meta: Decodable {
    let symbol: String
    enum CodingKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }
}

struct OHLC: Decodable {
    let open: String
    let close: String
    let adjustClose: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case close = "4. close"
        case adjustClose = "5. adjusted close"
    }
}
