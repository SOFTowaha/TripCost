//
//  SettingsView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var calculatorViewModel: TripCalculatorViewModel
    @State private var fuelPriceText = ""
    @State private var showCurrencyPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    unitsCard
                    currencyCard
                    fuelPricingCard
                    aboutCard
                }
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Settings")
            .onAppear {
                fuelPriceText = String(format: "%.3f", calculatorViewModel.fuelPrice)
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $calculatorViewModel.currencyCode)
            }
        }
    }
}

// MARK: - Subviews
extension SettingsView {
    private var unitsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "ruler")
                    .foregroundStyle(.blue)
                Text("Units")
                    .font(.headline)
            }

            Toggle(isOn: $calculatorViewModel.useMetric) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Metric System")
                    Text("Use kilometers instead of miles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var currencyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(.green)
                Text("Currency")
                    .font(.headline)
            }

            Button {
                showCurrencyPicker = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.green)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Currency")
                            .font(.body)
                        Text("Currently: \(calculatorViewModel.currencyCode)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .font(.caption)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var fuelPricingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "fuelpump.fill")
                    .foregroundStyle(.orange)
                Text("Fuel Pricing")
                    .font(.headline)
            }

            // Unit switcher (per gallon / per liter)
            Picker("Unit", selection: $calculatorViewModel.fuelPriceUnit) {
                Text("Per Gallon").tag(TripCalculatorViewModel.FuelPriceUnit.perGallon)
                Text("Per Liter").tag(TripCalculatorViewModel.FuelPriceUnit.perLiter)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(currencySymbol)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    TextField("Price per \(calculatorViewModel.fuelPriceLongUnitLabel)", text: $fuelPriceText)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .onChange(of: fuelPriceText) { _, newValue in
                            if let price = Double(newValue) {
                                calculatorViewModel.fuelPrice = price
                            }
                        }
                }

                HStack {
                    Text("Current: \(CurrencyFormatter.format(calculatorViewModel.fuelPrice, currencyCode: calculatorViewModel.currencyCode))/\(calculatorViewModel.fuelPriceLongUnitLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Quick conversion hint (show the alternate unit)
                    if calculatorViewModel.fuelPriceUnit == .perGallon {
                        Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice / 3.78541, currencyCode: calculatorViewModel.currencyCode))/L")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice * 3.78541, currencyCode: calculatorViewModel.currencyCode))/gal")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.purple)
                Text("About")
                    .font(.headline)
            }

            HStack(spacing: 12) {
                Text("Version")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 12) {
                Text("Build")
                Spacer()
                Text("2025.1").foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Helpers
extension SettingsView {
    private var currencySymbol: String {
        // Use the selected currency code to find a matching locale and symbol
        let code = calculatorViewModel.currencyCode
        for id in Locale.availableIdentifiers {
            let locale = Locale(identifier: id)
            if locale.currencyCode == code, let sym = locale.currencySymbol {
                return sym
            }
        }
        return "$"
    }
}
