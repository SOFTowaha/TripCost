//
//  AdditionalCost.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation

struct AdditionalCost: Identifiable, Codable, Hashable {
    let id: UUID
    var category: Category
    var amount: Double
    var notes: String
    
    var name: String {
        notes.isEmpty ? category.rawValue : notes
    }
    
    enum Category: String, Codable, CaseIterable {
        case food = "Food"
        case accommodation = "Accommodation"
        case parking = "Parking"
        case tolls = "Tolls"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .food: return "fork.knife"
            case .accommodation: return "bed.double.fill"
            case .parking: return "parkingsign.circle.fill"
            case .tolls: return "dollarsign.circle.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
    
    init(id: UUID = UUID(), category: Category, amount: Double, notes: String = "") {
        self.id = id
        self.category = category
        self.amount = amount
        self.notes = notes
    }
}
