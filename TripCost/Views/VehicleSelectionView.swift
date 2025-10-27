//
//  VehicleSelectionView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct VehicleSelectionView: View {
    @Environment(VehicleViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddVehicle = false
    @State private var showEditVehicle: Vehicle?
    @State private var hoverAddVehicle = false

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            ZStack {
                if viewModel.vehicles.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 18) {
                            ForEach(viewModel.vehicles) { vehicle in
                                VehicleCard(
                                    vehicle: vehicle,
                                    isSelected: viewModel.selectedVehicle?.id == vehicle.id,
                                    onSelect: {
                                        viewModel.selectedVehicle = vehicle
                                    },
                                    onEdit: {
                                        showEditVehicle = vehicle
                                    },
                                    onDelete: {
                                        viewModel.deleteVehicle(vehicle)
                                    }
                                )
                            }
                        }
                        .padding(24)
                    }
                }
            }
            .tcGlassBackground()
            .navigationTitle("My Vehicles")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Vehicle")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
                    .onTapGesture { showAddVehicle = true }
                    .onHover { hover in hoverAddVehicle = hover }
                    .opacity(hoverAddVehicle ? 0.85 : 1.0)
                    .help("Add Vehicle")
                    .accessibilityLabel("Add Vehicle")
                    .accessibilityAddTraits(.isButton)
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

struct VehicleCard: View {
    let vehicle: Vehicle
    var isSelected: Bool = false
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: vehicle.fuelType.icon)
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.displayName)
                        .font(.headline)
                    HStack(spacing: 8) {
                        Label("\(Int(vehicle.combinedMPG)) MPG", systemImage: "gauge.with.dots.needle.67percent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(vehicle.fuelType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1), in: Capsule())
                            .foregroundStyle(.blue)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else if vehicle.isCustom {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            HStack(spacing: 12) {
                Button {
                    onSelect()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        Text(isSelected ? "Selected" : "Select")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        isSelected ? .blue.opacity(0.15) : .gray.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isSelected)

                Button {
                    onEdit()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .modifier(GlassCardModifier(config: .init(cornerRadius: 18), tint: .blue))
    }
}
