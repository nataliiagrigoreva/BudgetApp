//
//  DateAxisValueFormatter.swift
//  finance
//
//  Created by Nataly on 16.05.2023.
//

import Foundation
import UIKit
import Charts

class DateAxisValueFormatter: IndexAxisValueFormatter {
    
    private let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        super.init()
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
}

