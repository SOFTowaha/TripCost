//
//  UserDefaultsService.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation

class UserDefaultsService {
    private let vehiclesKey = "savedVehicles"
    private let defaults = UserDefaults.standard
    
    func saveVehicles(_ vehicles: [Vehicle]) {
        if let encoded = try? JSONEncoder().encode(vehicles) {
            defaults.set(encoded, forKey: vehiclesKey)
        }
    }
    
    func loadVehicles() -> [Vehicle] {
        guard let data = defaults.data(forKey: vehiclesKey),
              let vehicles = try? JSONDecoder().decode([Vehicle].self, from: data) else {
            return []
        }
        return vehicles
    }
}
