//
//  TripRoute.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import MapKit
import CoreLocation

struct TripRoute: Identifiable, Codable, Hashable {
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
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, startAddress, endAddress, distance, expectedTravelTime
        case startLatitude, startLongitude, endLatitude, endLongitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startAddress = try container.decode(String.self, forKey: .startAddress)
        endAddress = try container.decode(String.self, forKey: .endAddress)
        distance = try container.decode(Double.self, forKey: .distance)
        expectedTravelTime = try container.decode(TimeInterval.self, forKey: .expectedTravelTime)
        
        let startLat = try container.decode(Double.self, forKey: .startLatitude)
        let startLon = try container.decode(Double.self, forKey: .startLongitude)
        startLocation = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        
        let endLat = try container.decode(Double.self, forKey: .endLatitude)
        let endLon = try container.decode(Double.self, forKey: .endLongitude)
        endLocation = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
        
        route = nil // MKRoute is not codable, so we don't persist it
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startAddress, forKey: .startAddress)
        try container.encode(endAddress, forKey: .endAddress)
        try container.encode(distance, forKey: .distance)
        try container.encode(expectedTravelTime, forKey: .expectedTravelTime)
        try container.encode(startLocation.latitude, forKey: .startLatitude)
        try container.encode(startLocation.longitude, forKey: .startLongitude)
        try container.encode(endLocation.latitude, forKey: .endLatitude)
        try container.encode(endLocation.longitude, forKey: .endLongitude)
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TripRoute, rhs: TripRoute) -> Bool {
        lhs.id == rhs.id
    }
}
