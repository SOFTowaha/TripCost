//
//  VehicleAPIService.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation

class VehicleAPIService {
    private let baseURL = "https://api.api-ninjas.com/v1/cars"
    /// API Ninjas key loaded from configuration
    /// Priority defined in `ConfigurationManager.vehicleAPIKey`
    private var apiKey: String? {
        ConfigurationManager.shared.vehicleAPIKey
    }
    
    func fetchVehicles(make: String? = nil, model: String? = nil, year: Int? = nil) async throws -> [Vehicle] {
        var components = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = []
        
        if let make = make {
            queryItems.append(URLQueryItem(name: "make", value: make))
        }
        if let model = model {
            queryItems.append(URLQueryItem(name: "model", value: model))
        }
        if let year = year {
            queryItems.append(URLQueryItem(name: "year", value: String(year)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: "50"))
        
        components.queryItems = queryItems
        
        guard let url = components.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        guard let key = apiKey, !key.isEmpty else {
            throw APIError.missingAPIKey
        }
        request.setValue(key, forHTTPHeaderField: "X-Api-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let apiVehicles = try JSONDecoder().decode([APIVehicle].self, from: data)
        return apiVehicles.map { $0.toVehicle() }
    }
    
    enum APIError: Error {
        case invalidResponse
        case decodingError
        case missingAPIKey
    }
}

struct APIVehicle: Codable {
    let make: String
    let model: String
    let year: Int
    let fuelType: String
    let cityMpg: Double
    let highwayMpg: Double
    let combinationMpg: Double
    
    enum CodingKeys: String, CodingKey {
        case make, model, year
        case fuelType = "fuel_type"
        case cityMpg = "city_mpg"
        case highwayMpg = "highway_mpg"
        case combinationMpg = "combination_mpg"
    }
    
    func toVehicle() -> Vehicle {
        let fuelType: Vehicle.FuelType
        switch self.fuelType.lowercased() {
        case "gas", "gasoline":
            fuelType = .gasoline
        case "diesel":
            fuelType = .diesel
        case "electricity", "electric":
            fuelType = .electric
        default:
            fuelType = .gasoline
        }
        
        return Vehicle(
            make: make,
            model: model,
            year: year,
            fuelType: fuelType,
            cityMPG: cityMpg,
            highwayMPG: highwayMpg,
            combinedMPG: combinationMpg,
            isCustom: false
        )
    }
}
