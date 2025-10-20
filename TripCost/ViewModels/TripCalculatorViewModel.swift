//
//  TripCalculatorViewModel.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import Combine

@MainActor
@Observable
class TripCalculatorViewModel {
    var tripRoute: TripRoute?
    var selectedVehicle: Vehicle?
    var fuelPrice: Double = 3.50
    var additionalCosts: [AdditionalCost] = []
    var useMetric = false
    var numberOfPeople = 1
    
    var tripCost: TripCost? {
        guard let route = tripRoute, let vehicle = selectedVehicle else { return nil }
        let fuelCost = calculateFuelCost(route: route, vehicle: vehicle)
        return TripCost(fuelCost: fuelCost, additionalCosts: additionalCosts)
    }
    
    var distanceDisplay: String {
        guard let route = tripRoute else { return "0" }
        if useMetric {
            return String(format: "%.1f km", route.distanceInKilometers())
        } else {
            return String(format: "%.1f miles", route.distanceInMiles())
        }
    }
    
    func calculateFuelCost(route: TripRoute, vehicle: Vehicle) -> Double {
        let distance = useMetric ? route.distanceInKilometers() : route.distanceInMiles()
        guard vehicle.fuelType != .electric else { return 0 }
        
        let mpg = vehicle.combinedMPG
        let gallonsNeeded = distance / mpg
        return gallonsNeeded * fuelPrice
    }
    
    func addAdditionalCost(_ cost: AdditionalCost) {
        additionalCosts.append(cost)
    }
    
    func removeAdditionalCost(_ cost: AdditionalCost) {
        additionalCosts.removeAll { $0.id == cost.id }
    }
    
    func updateAdditionalCost(_ cost: AdditionalCost) {
        if let index = additionalCosts.firstIndex(where: { $0.id == cost.id }) {
            additionalCosts[index] = cost
        }
    }
    
    func totalCostPerPerson() -> Double {
        guard let cost = tripCost else { return 0 }
        return cost.costPerPerson(numberOfPeople: numberOfPeople)
    }
    
    func reset() {
        tripRoute = nil
        selectedVehicle = nil
        additionalCosts = []
        numberOfPeople = 1
    }
}
