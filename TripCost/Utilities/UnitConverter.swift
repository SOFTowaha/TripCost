//
//  UnitConverter.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation

struct UnitConverter {
    static func metersToMiles(_ meters: Double) -> Double {
        return meters * 0.000621371
    }
    
    static func metersToKilometers(_ meters: Double) -> Double {
        return meters / 1000.0
    }
    
    static func mpgToKmpl(_ mpg: Double) -> Double {
        return mpg * 0.425144
    }
}
