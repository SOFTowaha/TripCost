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
            ScrollView {
                VStack(spacing: 18) {
                    vehicleInfoCard
                    mpgCard
                    Button {
                        saveVehicle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                            Text("Save Vehicle")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                        )
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFormValid)
                }
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private extension AddVehicleView {
    var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.blue)
                Text("Vehicle Information")
                    .font(.headline)
            }
            TextField("Make", text: $make)
                .textFieldStyle(.roundedBorder)
            TextField("Model", text: $model)
                .textFieldStyle(.roundedBorder)
            Picker("Year", selection: $year) {
                ForEach((2000...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.menu)
            Picker("Fuel Type", selection: $fuelType) {
                ForEach(Vehicle.FuelType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    var mpgCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .foregroundStyle(.green)
                Text("Fuel Efficiency (MPG)")
                    .font(.headline)
            }
            TextField("City MPG", text: $cityMPG)
                .textFieldStyle(.roundedBorder)
            TextField("Highway MPG", text: $highwayMPG)
                .textFieldStyle(.roundedBorder)
            TextField("Combined MPG", text: $combinedMPG)
                .textFieldStyle(.roundedBorder)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
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
