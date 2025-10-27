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
                    Button(action: saveVehicle) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Add Vehicle")
                                .fontWeight(.light)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(2)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
//                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
                .padding(24)
            }
            .background(.clear)
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 480, maxWidth: 600, minHeight: 500, idealHeight: 600, maxHeight: 700)
    }

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
                ForEach((2000...Calendar.current.component(.year, from: Date())).reversed(), id: \ .self) { y in
                    Text(String(y)).tag(y)
                }
            }
            .pickerStyle(.menu)
            Picker("Fuel Type", selection: $fuelType) {
                ForEach(Vehicle.FuelType.allCases, id: \ .self) { type in
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


    private func saveVehicle() {
        guard !make.isEmpty, !model.isEmpty,
              let city = Double(cityMPG),
              let highway = Double(highwayMPG),
              let combined = Double(combinedMPG) else {
            // Optionally show an error message
            return
        }
        let newVehicle = Vehicle(
            make: make,
            model: model,
            year: year,
            fuelType: fuelType,
            cityMPG: city,
            highwayMPG: highway,
            combinedMPG: combined,
            isCustom: true
        )
        viewModel.addCustomVehicle(newVehicle)
        dismiss()
    }
//
//                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
//
//            )

        }

        




