import SwiftUI
import Foundation

@MainActor
@Observable
class SavedTripsViewModel {
    var savedTrips: [SavedTrip] = []
    private let fileService = SavedTripFileService.shared
    
    init() {
        loadTrips()
    }
    
    func loadTrips() {
        savedTrips = fileService.loadTrips()
    }
    
    func saveTrip(name: String, route: TripRoute, vehicle: Vehicle, cost: Double, currency: Currency, additionalCosts: [AdditionalCost], notes: String?, numberOfPeople: Int = 1, costPerPerson: Double = 0) {
        let trip = SavedTrip(
            name: name,
            route: route,
            vehicle: vehicle,
            cost: cost,
            currency: currency,
            additionalCosts: additionalCosts,
            notes: notes,
            numberOfPeople: numberOfPeople,
            costPerPerson: costPerPerson
        )
        fileService.addTrip(trip)
        loadTrips()
    }
    
    func deleteTrip(_ trip: SavedTrip) {
        fileService.deleteTrip(trip)
        loadTrips()
    }
    
    func updateTrip(_ trip: SavedTrip) {
        fileService.updateTrip(trip)
        loadTrips()
    }
}
