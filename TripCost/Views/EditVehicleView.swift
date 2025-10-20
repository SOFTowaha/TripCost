//
    // ...existing code...

import SwiftUI

    // Move these back inside the struct so they have access to state
    var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.blue)
                Text("Vehicle")
                    .font(.headline)
            }
            LabeledContent("Make", value: vehicle.make)
            LabeledContent("Model", value: vehicle.model)
            LabeledContent("Year", value: String(vehicle.year))
            LabeledContent("Fuel Type", value: vehicle.fuelType.rawValue)
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
                Text("Edit Fuel Efficiency (MPG)")
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
    
            
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Vehicle")
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
            .onAppear {
                cityMPG = String(vehicle.cityMPG)
                highwayMPG = String(vehicle.highwayMPG)
                combinedMPG = String(vehicle.combinedMPG)
            }
        }
    


private extension EditVehicleView {
    var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.blue)
                Text("Vehicle")
                        // ...existing code...
                    }

        dismiss()
                        fileprivate var vehicleInfoCard: some View {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "car.fill")
                                        .foregroundStyle(.blue)
                                    Text("Vehicle")
                                        .font(.headline)
                                }
                                LabeledContent("Make", value: vehicle.make)
                                LabeledContent("Model", value: vehicle.model)
                                LabeledContent("Year", value: String(vehicle.year))
                                LabeledContent("Fuel Type", value: vehicle.fuelType.rawValue)
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }

                        fileprivate var mpgCard: some View {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "gauge.with.dots.needle.67percent")
                                        .foregroundStyle(.green)
                                    Text("Edit Fuel Efficiency (MPG)")
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
}
