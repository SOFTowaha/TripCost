//
//  AddVehicleView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct AddVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: VehicleViewModel

    @State private var make = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var fuelType: Vehicle.FuelType = .gasoline
    @State private var cityMPG = ""
    @State private var highwayMPG = ""
    @State private var combinedMPG = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Information") {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    Picker("Year", selection: $year) {
                        ForEach((2000...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                    Picker("Fuel Type", selection: $fuelType) {
                        ForEach(Vehicle.FuelType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }
                }
                Section("Fuel Efficiency (MPG)") {
                    TextField("City MPG", text: $cityMPG)
                    TextField("Highway MPG", text: $highwayMPG)
                    TextField("Combined MPG", text: $combinedMPG)
                }
                Section {
                    Button("Save Vehicle") { saveVehicle() }
                        .frame(maxWidth: .infinity)
                        .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !make.isEmpty && !model.isEmpty && Double(cityMPG) != nil && Double(highwayMPG) != nil && Double(combinedMPG) != nil
    }

    private func saveVehicle() {
        guard let city = Double(cityMPG), let highway = Double(highwayMPG), let combined = Double(combinedMPG) else { return }
        let vehicle = Vehicle(make: make, model: model, year: year, fuelType: fuelType, cityMPG: city, highwayMPG: highway, combinedMPG: combined, isCustom: true)
        viewModel.addCustomVehicle(vehicle)
        dismiss()
    }
}
