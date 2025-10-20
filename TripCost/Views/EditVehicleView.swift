//
//  EditVehicleView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: VehicleViewModel
    let vehicle: Vehicle

    @State private var cityMPG = ""
    @State private var highwayMPG = ""
    @State private var combinedMPG = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle") {
                    LabeledContent("Make", value: vehicle.make)
                    LabeledContent("Model", value: vehicle.model)
                    LabeledContent("Year", value: String(vehicle.year))
                    LabeledContent("Fuel Type", value: vehicle.fuelType.rawValue)
                }
                Section("Edit Fuel Efficiency (MPG)") {
                    TextField("City MPG", text: $cityMPG)
                    TextField("Highway MPG", text: $highwayMPG)
                    TextField("Combined MPG", text: $combinedMPG)
                }
                Section {
                    Button("Save Changes") { saveChanges() }
                        .frame(maxWidth: .infinity)
                        .disabled(!isFormValid)
                }
            }
            .navigationTitle("Edit Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                cityMPG = String(vehicle.cityMPG)
                highwayMPG = String(vehicle.highwayMPG)
                combinedMPG = String(vehicle.combinedMPG)
            }
        }
    }

    private var isFormValid: Bool {
        Double(cityMPG) != nil && Double(highwayMPG) != nil && Double(combinedMPG) != nil
    }

    private func saveChanges() {
        guard let city = Double(cityMPG), let highway = Double(highwayMPG), let combined = Double(combinedMPG) else { return }
        viewModel.updateVehicleMPG(vehicle, cityMPG: city, highwayMPG: highway, combinedMPG: combined)
        dismiss()
    }
}
