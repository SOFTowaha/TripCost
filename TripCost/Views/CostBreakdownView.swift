//
//  CostBreakdownView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct CostBreakdownView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var calculatorViewModel: TripCalculatorViewModel
    @Bindable var vehicleViewModel: VehicleViewModel
    @State private var showAddCost = false
    @State private var showSplitView = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Debug info - remove later
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Info:").font(.caption).fontWeight(.bold)
                        Text("Vehicles count: \(vehicleViewModel.vehicles.count)")
                        Text("Selected vehicle: \(vehicleViewModel.selectedVehicle?.displayName ?? "None")")
                        if !vehicleViewModel.vehicles.isEmpty {
                            Text("Available vehicles:")
                            ForEach(vehicleViewModel.vehicles.prefix(3)) { vehicle in
                                Text("  - \(vehicle.displayName)")
                            }
                        }
                    }
                    .font(.caption)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    
                    if vehicleViewModel.selectedVehicle == nil {
                        selectVehiclePrompt
                    } else {
                        totalCostCard
                        fuelCostCard
                        additionalCostsSection
                        splitCostButton
                    }
                }
                .padding()
            }
            .navigationTitle("Cost Breakdown")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                if vehicleViewModel.selectedVehicle != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button { showAddCost = true } label: { Image(systemName: "plus.circle.fill") }
                    }
                }
            }
            .sheet(isPresented: $showAddCost) {
                AddCostView(calculatorViewModel: calculatorViewModel)
            }
            .sheet(isPresented: $showSplitView) {
                CostSplitView(calculatorViewModel: calculatorViewModel)
            }
        }
    }

    private var selectVehiclePrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "car.circle.fill").font(.system(size: 60)).foregroundStyle(.secondary)
            Text("Select a Vehicle").font(.title2).fontWeight(.semibold)
            Text("Choose a vehicle to calculate fuel costs")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            
            // Show available vehicles if any exist
            if !vehicleViewModel.vehicles.isEmpty {
                VStack(spacing: 8) {
                    Text("Available Vehicles:").font(.headline).padding(.top, 8)
                    ForEach(vehicleViewModel.vehicles) { vehicle in
                        Button {
                            vehicleViewModel.selectedVehicle = vehicle
                            print("✅ Selected vehicle in Cost Breakdown: \(vehicle.displayName)")
                        } label: {
                            HStack {
                                Image(systemName: vehicle.fuelType.icon)
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading) {
                                    Text(vehicle.displayName)
                                        .font(.headline)
                                    Text("\(Int(vehicle.combinedMPG)) MPG")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding().frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var totalCostCard: some View {
        VStack(spacing: 12) {
            Text("Total Trip Cost").font(.subheadline).foregroundStyle(.secondary)
            Text(CurrencyFormatter.format(calculatorViewModel.tripCost?.totalCost ?? 0))
                .font(.system(size: 40, weight: .bold, design: .rounded))
            if calculatorViewModel.numberOfPeople > 1 {
                Text("\(CurrencyFormatter.format(calculatorViewModel.totalCostPerPerson())) per person")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 16))
    }

    private var fuelCostCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fuelpump.fill").foregroundStyle(.blue)
                Text("Fuel Cost").font(.headline)
                Spacer()
                Text(CurrencyFormatter.format(calculatorViewModel.tripCost?.fuelCost ?? 0))
                    .font(.headline).fontWeight(.bold)
            }
            if let vehicle = vehicleViewModel.selectedVehicle {
                Divider()
                VStack(spacing: 8) {
                    InfoRow(label: "Vehicle", value: vehicle.displayName)
                    InfoRow(label: "Fuel Efficiency", value: "\(Int(vehicle.combinedMPG)) MPG")
                    InfoRow(label: "Distance", value: calculatorViewModel.distanceDisplay)
                    InfoRow(label: "Fuel Price", value: CurrencyFormatter.format(calculatorViewModel.fuelPrice) + "/gal")
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var additionalCostsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Additional Costs").font(.headline)
                Spacer()
                Text(CurrencyFormatter.format(calculatorViewModel.additionalCosts.reduce(0) { $0 + $1.amount }))
                    .font(.headline).fontWeight(.bold)
            }
            if calculatorViewModel.additionalCosts.isEmpty {
                Text("No additional costs added")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(calculatorViewModel.additionalCosts) { cost in
                    AdditionalCostRow(cost: cost) {
                        calculatorViewModel.removeAdditionalCost(cost)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var splitCostButton: some View {
        Button {
            showSplitView = true
        } label: {
            HStack {
                Image(systemName: "person.3.fill")
                Text("Split Cost")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium)
        }
    }
}

struct AdditionalCostRow: View {
    let cost: AdditionalCost
    let onDelete: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: cost.category.icon).foregroundStyle(.blue).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(cost.category.rawValue).font(.subheadline).fontWeight(.medium)
                if !cost.notes.isEmpty {
                    Text(cost.notes).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer()
            Text(CurrencyFormatter.format(cost.amount)).font(.subheadline).fontWeight(.semibold)
            Button(role: .destructive, action: onDelete) { Image(systemName: "trash").font(.caption) }
        }
        .padding(.vertical, 8)
    }
}
