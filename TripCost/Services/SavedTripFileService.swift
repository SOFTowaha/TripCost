import Foundation

class SavedTripFileService {
    static let shared = SavedTripFileService()
    private let fileName = "saved_trips.json"
    
    private var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }
    
    func loadTrips() -> [SavedTrip] {
        guard let url = fileURL, FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            let trips = try JSONDecoder().decode([SavedTrip].self, from: data)
            return trips
        } catch {
            print("❌ Failed to load trips: \(error)")
            return []
        }
    }
    
    func saveTrips(_ trips: [SavedTrip]) {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(trips)
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ Failed to save trips: \(error)")
        }
    }
    
    func addTrip(_ trip: SavedTrip) {
        var trips = loadTrips()
        trips.append(trip)
        saveTrips(trips)
    }
    
    func deleteTrip(_ trip: SavedTrip) {
        var trips = loadTrips()
        trips.removeAll { $0.id == trip.id }
        saveTrips(trips)
    }
    
    func updateTrip(_ trip: SavedTrip) {
        var trips = loadTrips()
        if let idx = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[idx] = trip
            saveTrips(trips)
        }
    }
}
