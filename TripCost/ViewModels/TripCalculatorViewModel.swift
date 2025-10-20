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
    // Removed selectedVehicle - will use from VehicleViewModel
    var fuelPrice: Double = 3.50
    enum FuelPriceUnit: String, Codable { case perGallon, perLiter }
    var fuelPriceUnit: FuelPriceUnit = .perGallon
    var additionalCosts: [AdditionalCost] = []
    var useMetric = false
    var numberOfPeople = 1
    var currencyCode = "CAD" // New: Currency selection
    
    func tripCost(vehicle: Vehicle?) -> TripCost? {
        guard let route = tripRoute else {
            print("❌ No route available for cost calculation")
            return nil
        }
        guard let vehicle = vehicle else {
            print("❌ No vehicle selected for cost calculation")
            return nil
        }
        
        print("✅ Calculating cost with route: \(route.distanceInMiles()) miles, vehicle: \(vehicle.displayName)")
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
        guard vehicle.fuelType != .electric else { return 0 }
        
        // Always calculate using miles and MPG
        let distanceInMiles = route.distanceInMiles()
        let mpg = vehicle.combinedMPG
        let gallonsNeeded = distanceInMiles / mpg
        let litersPerGallon = 3.78541
        let cost: Double
        switch fuelPriceUnit {
        case .perGallon:
            cost = gallonsNeeded * fuelPrice
        case .perLiter:
            // Convert liters price to per-trip cost using liters consumed
            cost = (gallonsNeeded * litersPerGallon) * fuelPrice
        }
        
        print("🧮 Fuel Calculation:")
        print("  Distance: \(String(format: "%.2f", distanceInMiles)) miles")
        print("  MPG: \(mpg)")
        print("  Gallons needed: \(String(format: "%.2f", gallonsNeeded))")
        let unitText = fuelPriceUnit == .perGallon ? "per gallon" : "per liter"
        print("  Fuel price: $\(fuelPrice) / \(unitText)")
        print("  Total fuel cost: $\(String(format: "%.2f", cost))")
        
        return cost
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
    
    func totalCostPerPerson(vehicle: Vehicle?) -> Double {
        guard let cost = tripCost(vehicle: vehicle) else { return 0 }
        return cost.costPerPerson(numberOfPeople: numberOfPeople)
    }
    
    func reset() {
        tripRoute = nil
        additionalCosts = []
        numberOfPeople = 1
    }

    // MARK: - Display Helpers
    var fuelPriceLongUnitLabel: String { fuelPriceUnit == .perGallon ? "gallon" : "liter" }
    var fuelPriceShortUnitLabel: String { fuelPriceUnit == .perGallon ? "gal" : "L" }
}
