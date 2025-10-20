//
//  VehicleViewModel.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import Combine

@MainActor
@Observable
class VehicleViewModel {
    var vehicles: [Vehicle] = [] {
            didSet { saveVehicles() } // persist custom vehicles
        }
    var selectedVehicle: Vehicle?
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""
    
    private let apiService = VehicleAPIService()
    private let storage = UserDefaultsService()
    
    init() {
        loadSavedVehicles()
    }
    
    func searchVehicles(make: String? = nil, model: String? = nil, year: Int? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedVehicles = try await apiService.fetchVehicles(
                make: make,
                model: model,
                year: year
            )
            vehicles = fetchedVehicles
        } catch {
            errorMessage = "Failed to fetch vehicles: \(error.localizedDescription)"
        }
    }
    
    func addCustomVehicle(_ vehicle: Vehicle) {
        var customVehicle = vehicle
        customVehicle.isCustom = true
        vehicles.append(customVehicle)
        saveVehicles()
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        if selectedVehicle?.id == vehicle.id {
            selectedVehicle = nil
        }
        saveVehicles()
    }
    
    func updateVehicleMPG(_ vehicle: Vehicle, cityMPG: Double, highwayMPG: Double, combinedMPG: Double) {
        if let idx = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            var v = vehicles[idx]
            v.cityMPG = cityMPG
            v.highwayMPG = highwayMPG
            v.combinedMPG = combinedMPG
            vehicles[idx] = v // replace to trigger view update
        }
    }
    
    private func saveVehicles() {
        storage.saveVehicles(vehicles.filter { $0.isCustom })
    }
    
    private func loadSavedVehicles() {
        vehicles = storage.loadVehicles()
    }
}
