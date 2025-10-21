//
//  ContentView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

//struct ContentView: View {
//    @State private var selectedTab = 0
//    @State private var locationViewModel = LocationViewModel()
//    @State private var vehicleViewModel = VehicleViewModel()
//    @State private var calculatorViewModel = TripCalculatorViewModel()
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            MapSelectionView(
//                locationViewModel: locationViewModel,
//                calculatorViewModel: calculatorViewModel,
//                vehicleViewModel: vehicleViewModel
//            )
//            .tabItem {
//                Label("Trip", systemImage: "map.fill")
//            }
//            .tag(0)
//            
//            VehicleSelectionView(viewModel: vehicleViewModel)
//                .tabItem {
//                    Label("Vehicles", systemImage: "car.fill")
//                }
//                .tag(1)
//            
//            SettingsView(calculatorViewModel: calculatorViewModel)
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape.fill")
//                }
//                .tag(2)
//        }
//        .tint(.blue)
//    }
//}
struct ContentView: View {
    @Environment(LocationViewModel.self) private var locationVM
    @Environment(VehicleViewModel.self) private var vehicleVM
    @Environment(TripCalculatorViewModel.self) private var calcVM
    @Environment(SavedTripsViewModel.self) private var savedTripsVM

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MapSelectionView(
                locationViewModel: locationVM,
                calculatorViewModel: calcVM,
                vehicleViewModel: vehicleVM
            )
                .tabItem { Label("Trip", systemImage: "map.fill") }
                .tag(0)
            VehicleSelectionView()
                .tabItem { Label("Vehicles", systemImage: "car.fill") }
                .tag(1)
            SavedTripsView()
                .tabItem { Label("Saved", systemImage: "bookmark.fill") }
                .tag(2)
            SettingsView(calculatorViewModel: calcVM)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
    }
}
