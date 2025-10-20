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
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Cost Breakdown")
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
                
                if vehicleViewModel.selectedVehicle != nil {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            showCurrencyPicker = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "dollarsign.circle.fill")
                                Text(calculatorViewModel.currencyCode)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showAddCost = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Cost")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                            )
                            .foregroundStyle(.blue)
                            .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .sheet(isPresented: $showAddCost) {
                AddCostView(calculatorViewModel: calculatorViewModel)
            }
            .sheet(isPresented: $showSplitView) {
                CostSplitView(calculatorViewModel: calculatorViewModel, vehicleViewModel: vehicleViewModel)
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
                                print("✅ Vehicle selected in Cost Breakdown: \(vehicle.displayName)")
                                print("   MPG: \(vehicle.combinedMPG)")
                                print("   Fuel Type: \(vehicle.fuelType.rawValue)")
                                
                                // Force recalculation by accessing tripCost
                                if let cost = calculatorViewModel.tripCost(vehicle: vehicle) {
                                    print("   Calculated Fuel Cost: $\(cost.fuelCost)")
                                    print("   Total Cost: $\(cost.totalCost)")
                                }
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
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Trip Cost")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Text(CurrencyFormatter.format(calculatorViewModel.tripCost(vehicle: vehicleViewModel.selectedVehicle)?.totalCost ?? 0, currencyCode: calculatorViewModel.currencyCode))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue.opacity(0.4))
            }
            
            if calculatorViewModel.numberOfPeople > 1 {
                Divider()
                    .opacity(0.5)
                
                HStack {
                    Label("Per Person", systemImage: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(CurrencyFormatter.format(calculatorViewModel.totalCostPerPerson(vehicle: vehicleViewModel.selectedVehicle), currencyCode: calculatorViewModel.currencyCode))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: .blue.opacity(0.2), radius: 16, x: 0, y: 8)
    }

    private var fuelCostCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "fuelpump.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text("Fuel Cost")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                Text(CurrencyFormatter.format(calculatorViewModel.tripCost(vehicle: vehicleViewModel.selectedVehicle)?.fuelCost ?? 0, currencyCode: calculatorViewModel.currencyCode))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
            if let vehicle = vehicleViewModel.selectedVehicle {
                Divider()
                    .opacity(0.5)
                VStack(spacing: 12) {
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
                        value: CurrencyFormatter.format(calculatorViewModel.fuelPrice, currencyCode: calculatorViewModel.currencyCode) + "/" + calculatorViewModel.fuelPriceShortUnitLabel
                    )
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private var additionalCostsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "plus.square.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("Additional Costs")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Text(CurrencyFormatter.format(
                    calculatorViewModel.additionalCosts.reduce(0) { $0 + $1.amount },
                    currencyCode: calculatorViewModel.currencyCode
                ))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
            
            if calculatorViewModel.additionalCosts.isEmpty {
                    Divider()
                        .opacity(0.5)
                
                    VStack(spacing: 10) {
                        Image(systemName: "tray")
                            .font(.system(size: 36))
                            .foregroundStyle(.tertiary)
                    
                        Text("No additional costs")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                    Divider()
                        .opacity(0.5)
                
                    VStack(spacing: 10) {
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
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private var splitCostButton: some View {
        Button {
            showSplitView = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.3.fill")
                    .font(.title3)
                Text("Split Cost Among People")
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
            )
            .foregroundStyle(.green)
            .shadow(color: .green.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    var icon: String? = nil
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
            }
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct AdditionalCostRow: View {
    let cost: AdditionalCost
    let currencyCode: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: cost.category.icon)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(cost.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !cost.notes.isEmpty {
                    Text(cost.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(cost.amount, currencyCode: currencyCode))
                .font(.subheadline)
                .fontWeight(.bold)
            
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Currency Picker View
struct CurrencyPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCurrency: String
    @State private var query: String = ""
    
    let currencies = [
        ("USD", "US Dollar", "$"),
        ("EUR", "Euro", "€"),
        ("GBP", "British Pound", "£"),
        ("JPY", "Japanese Yen", "¥"),
        ("CAD", "Canadian Dollar", "C$"),
        ("AUD", "Australian Dollar", "A$"),
        ("CHF", "Swiss Franc", "CHF"),
        ("CNY", "Chinese Yuan", "¥"),
        ("INR", "Indian Rupee", "₹"),
        ("MXN", "Mexican Peso", "$")
    ]
    
    // Map currency code to a representative region code for flag rendering
    private let currencyRegionMap: [String: String] = [
        "USD": "US",
        "EUR": "EU",
        "GBP": "GB",
        "JPY": "JP",
        "CAD": "CA",
        "AUD": "AU",
        "CHF": "CH",
        "CNY": "CN",
        "INR": "IN",
        "MXN": "MX"
    ]
    
    private var filteredCurrencies: [(String, String, String)] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return currencies }
        return currencies.filter { code, name, symbol in
            code.lowercased().contains(q) || name.lowercased().contains(q) || symbol.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    searchBar
                    ForEach(filteredCurrencies, id: \.0) { code, name, symbol in
                        Button {
                            selectedCurrency = code
                            dismiss()
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCurrency == code ? .blue.opacity(0.12) : .gray.opacity(0.12))
                                        .frame(width: 46, height: 46)

                                    Text(flagEmoji(for: currencyRegionMap[code] ?? "US"))
                                        .font(.title2)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name)
                                        .font(.headline)
                                    HStack(spacing: 6) {
                                        Text(code)
                                        Text(symbol)
                                            .foregroundStyle(.secondary)
                                    }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if selectedCurrency == code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Select Currency")
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
        .frame(minWidth: 480, minHeight: 560)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search currency, code, or symbol", text: $query)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Flag Helpers
    private func flagEmoji(for regionCode: String) -> String {
        let upper = regionCode.uppercased()
        var scalarView = String.UnicodeScalarView()
        for u in upper.unicodeScalars {
            guard let flagScalar = UnicodeScalar(127397 + Int(u.value)) else { continue }
            scalarView.append(flagScalar)
        }
        return String(scalarView)
    }
}
