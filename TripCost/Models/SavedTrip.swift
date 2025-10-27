import Foundation
import MapKit

struct SavedTrip: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var date: Date
    var route: TripRoute
    var vehicle: Vehicle
    var cost: Double
    var currency: Currency
    var additionalCosts: [AdditionalCost]
    var notes: String?
    // Camping checklist items (optional for backward compatibility)
    var campingChecklist: [ChecklistItem]? // treat nil as [] in UI
    var numberOfPeople: Int
    var costPerPerson: Double
    // For sharing
    var shareURL: URL? // Optional: for future deep-linking or export
    
    init(id: UUID = UUID(),
         name: String,
         date: Date = Date(),
         route: TripRoute,
         vehicle: Vehicle,
         cost: Double,
         currency: Currency,
         additionalCosts: [AdditionalCost] = [],
         notes: String? = nil,
         campingChecklist: [ChecklistItem]? = nil,
         numberOfPeople: Int = 1,
         costPerPerson: Double = 0,
         shareURL: URL? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.route = route
        self.vehicle = vehicle
        self.cost = cost
        self.currency = currency
        self.additionalCosts = additionalCosts
        self.notes = notes
        self.campingChecklist = campingChecklist
        self.numberOfPeople = numberOfPeople
        self.costPerPerson = costPerPerson
        self.shareURL = shareURL
    }
}
