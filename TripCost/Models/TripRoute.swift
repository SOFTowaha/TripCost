//
//  TripRoute.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import MapKit
import CoreLocation

struct TripRoute: Identifiable {
    let id: UUID
    var startLocation: CLLocationCoordinate2D
    var endLocation: CLLocationCoordinate2D
    var startAddress: String
    var endAddress: String
    var distance: Double // in meters
    var expectedTravelTime: TimeInterval
    var route: MKRoute?
    
    init(id: UUID = UUID(), startLocation: CLLocationCoordinate2D,
         endLocation: CLLocationCoordinate2D, startAddress: String = "",
         endAddress: String = "", distance: Double = 0,
         expectedTravelTime: TimeInterval = 0, route: MKRoute? = nil) {
        self.id = id
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.startAddress = startAddress
        self.endAddress = endAddress
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.route = route
    }
    
    func distanceInMiles() -> Double {
        return distance * 0.000621371
    }
    
    func distanceInKilometers() -> Double {
        return distance / 1000.0
    }
}
