import Foundation

struct Vehicle: Identifiable, Codable, Hashable {
    let id: UUID
    var make: String
    var model: String
    var year: Int
    var fuelType: FuelType
    var cityMPG: Double
    var highwayMPG: Double
    var combinedMPG: Double
    var isCustom: Bool
    
    enum FuelType: String, Codable, CaseIterable {
        case gasoline = "Gasoline"
        case diesel = "Diesel"
        case electric = "Electric"
        case hybrid = "Hybrid"
        
        var icon: String {
            switch self {
            case .gasoline: return "fuelpump.fill"
            case .diesel: return "fuelpump"
            case .electric: return "bolt.car.fill"
            case .hybrid: return "leaf.fill"
            }
        }
    }
    
    init(id: UUID = UUID(), make: String, model: String, year: Int,
         fuelType: FuelType, cityMPG: Double, highwayMPG: Double,
         combinedMPG: Double, isCustom: Bool = false) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.fuelType = fuelType
        self.cityMPG = cityMPG
        self.highwayMPG = highwayMPG
        self.combinedMPG = combinedMPG
        self.isCustom = isCustom
    }
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
}
