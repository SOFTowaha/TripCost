//
//  TripCostApp.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

// TripCostApp.swift
import SwiftUI

@main
struct TripCostApp: App {
    @State private var locationVM = LocationViewModel()
    @State private var vehicleVM = VehicleViewModel()
    @State private var calcVM = TripCalculatorViewModel()
    @State private var savedTripsVM = SavedTripsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(locationVM)
                .environment(vehicleVM)
                .environment(calcVM)
                .environment(savedTripsVM)
        }
    }
}
