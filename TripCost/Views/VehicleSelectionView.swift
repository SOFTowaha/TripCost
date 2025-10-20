//
//  VehicleSelectionView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct VehicleSelectionView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @State private var showAddVehicle = false
    @State private var showEditVehicle: Vehicle?

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Group {
                if viewModel.vehicles.isEmpty {
                    emptyState
                } else {
                    // Inline the vehicle list here to access bindable viewModel
                    List {
                        ForEach(viewModel.vehicles) { vehicle in
                            VehicleRow(
                                vehicle: vehicle,
                                isSelected: viewModel.selectedVehicle?.id == vehicle.id
                            )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    print("🔵 Tapping vehicle: \(vehicle.displayName)")
                                    viewModel.selectedVehicle = vehicle
                                    print("✅ Vehicle selected: \(vehicle.displayName)")
                                    print("✅ Current selected: \(viewModel.selectedVehicle?.displayName ?? "nil")")
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteVehicle(vehicle)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        showEditVehicle = vehicle
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("My Vehicles")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddVehicle = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }

            .sheet(isPresented: $showAddVehicle) {
                AddVehicleView(viewModel: viewModel)
            }
            .sheet(item: $showEditVehicle) { vehicle in
                EditVehicleView(viewModel: viewModel, vehicle: vehicle)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Vehicles")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add a vehicle to calculate trip costs")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddVehicle = true
            } label: {
                Text("Add Vehicle")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.blue, in: Capsule())
            }
        }
        .padding()
    }
}

struct VehicleRow: View {
    let vehicle: Vehicle
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: vehicle.fuelType.icon)
                .font(.title2)
                .foregroundStyle(isSelected ? .white : .blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.displayName)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)

                HStack(spacing: 8) {
                    Label("\(Int(vehicle.combinedMPG)) MPG", systemImage: "gauge.with.dots.needle.67percent")
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)

                    Text(vehicle.fuelType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isSelected ? .white.opacity(0.2) : .blue.opacity(0.1), in: Capsule())
                        .foregroundStyle(isSelected ? .white : .blue)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white)
                    .font(.title3)
            } else if vehicle.isCustom {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isSelected ? .blue : .clear, in: RoundedRectangle(cornerRadius: 8))
    }
}
