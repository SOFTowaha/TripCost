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
    @State private var showCurrencyPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
            .background(Color(.windowBackgroundColor).ignoresSafeArea())
            .navigationTitle("Cost Breakdown")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                            Text("Close")
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                if vehicleViewModel.selectedVehicle != nil {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            showCurrencyPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                Text(calculatorViewModel.currencyCode)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showAddCost = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Cost")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .sheet(isPresented: $showAddCost) {
                AddCostView(calculatorViewModel: calculatorViewModel)
            }
            .sheet(isPresented: $showSplitView) {
                CostSplitView(calculatorViewModel: calculatorViewModel)
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $calculatorViewModel.currencyCode)
            }
        }
    }

    private var selectVehiclePrompt: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                }
                
                Text("Select Your Vehicle")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Choose a vehicle to calculate accurate fuel costs for your trip")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !vehicleViewModel.vehicles.isEmpty {
                VStack(spacing: 12) {
                    ForEach(vehicleViewModel.vehicles) { vehicle in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                vehicleViewModel.selectedVehicle = vehicle
                            }
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(.blue.opacity(0.1))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: vehicle.fuelType.icon)
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vehicle.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    HStack(spacing: 12) {
                                        Label("\(Int(vehicle.combinedMPG)) MPG", systemImage: "gauge.with.dots.needle.67percent")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Text(vehicle.fuelType.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(.blue.opacity(0.1))
                                            .foregroundStyle(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No vehicles available. Add one in the Vehicles tab.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var totalCostCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Trip Cost")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(CurrencyFormatter.format(calculatorViewModel.tripCost?.totalCost ?? 0, currencyCode: calculatorViewModel.currencyCode))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue.opacity(0.3))
            }
            
            if calculatorViewModel.numberOfPeople > 1 {
                Divider()
                
                HStack {
                    Label("Per Person", systemImage: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(CurrencyFormatter.format(calculatorViewModel.totalCostPerPerson(), currencyCode: calculatorViewModel.currencyCode))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private var fuelCostCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "fuelpump.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                    Text("Fuel Cost")
                        .font(.headline)
                }
                
                Spacer()
                
                Text(CurrencyFormatter.format(calculatorViewModel.tripCost?.fuelCost ?? 0, currencyCode: calculatorViewModel.currencyCode))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            
            if let vehicle = vehicleViewModel.selectedVehicle {
                Divider()
                
                VStack(spacing: 10) {
                    InfoRow(
                        icon: "car.fill",
                        label: "Vehicle",
                        value: vehicle.displayName
                    )
                    InfoRow(
                        icon: "gauge.with.dots.needle.67percent",
                        label: "Fuel Efficiency",
                        value: "\(Int(vehicle.combinedMPG)) MPG"
                    )
                    InfoRow(
                        icon: "map.fill",
                        label: "Distance",
                        value: calculatorViewModel.distanceDisplay
                    )
                    InfoRow(
                        icon: "dollarsign.circle.fill",
                        label: "Fuel Price",
                        value: CurrencyFormatter.format(calculatorViewModel.fuelPrice, currencyCode: calculatorViewModel.currencyCode) + "/gal"
                    )
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var additionalCostsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "plus.square.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text("Additional Costs")
                        .font(.headline)
                }
                
                Spacer()
                
                Text(CurrencyFormatter.format(
                    calculatorViewModel.additionalCosts.reduce(0) { $0 + $1.amount },
                    currencyCode: calculatorViewModel.currencyCode
                ))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
            
            if calculatorViewModel.additionalCosts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 30))
                        .foregroundStyle(.tertiary)
                    
                    Text("No additional costs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(calculatorViewModel.additionalCosts) { cost in
                        AdditionalCostRow(cost: cost, currencyCode: calculatorViewModel.currencyCode) {
                            withAnimation {
                                calculatorViewModel.removeAdditionalCost(cost)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var splitCostButton: some View {
        Button {
            showSplitView = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .font(.headline)
                Text("Split Cost Among People")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.green, .green.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
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
