//
//  TripCost.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation

struct TripCost: Identifiable {
    let id: UUID
    var fuelCost: Double
    var additionalCosts: [AdditionalCost]
    var totalCost: Double {
        fuelCost + additionalCosts.reduce(0) { $0 + $1.amount }
    }
    
    init(id: UUID = UUID(), fuelCost: Double, additionalCosts: [AdditionalCost] = []) {
        self.id = id
        self.fuelCost = fuelCost
        self.additionalCosts = additionalCosts
    }
    
    func costPerPerson(numberOfPeople: Int) -> Double {
        guard numberOfPeople > 0 else { return totalCost }
        return totalCost / Double(numberOfPeople)
    }
}
