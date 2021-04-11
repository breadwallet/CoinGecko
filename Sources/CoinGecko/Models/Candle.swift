//
//  Candle.swift
//  
//
//  Created by stringcode on 05/04/2021.
//

import Foundation

public typealias CandleList = [Candle]

public struct Candle: Codable {
    public let date: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double

    public init(arrayData: [Double]) {
        date = Date(timeIntervalSince1970: Double(arrayData[0]) / 1000)
        open = arrayData[1]
        high = arrayData[2]
        low = arrayData[3]
        close = arrayData[4]
    }
    
    public init(date: Date, open: Double, high: Double, low: Double, close: Double) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
}
