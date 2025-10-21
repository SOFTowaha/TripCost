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
        self.shareURL = shareURL
    }
}
