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
    
    @State private var showSaved = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 20) {
                        unitsCard
                        currencyCard
                        fuelPricingCard
                        weatherConfigCard
                        vehicleConfigCard
                        aboutCard
                    }
                    .padding(24)
                }
                .tcGlassBackground()
                if showSaved {
                    HStack {
                        Spacer()
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .font(.title3)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(
                                Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .green.opacity(0.15), radius: 8, x: 0, y: 4)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                fuelPriceText = String(format: "%.3f", calculatorViewModel.fuelPrice)
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $calculatorViewModel.currency)
            }
            .onChange(of: calculatorViewModel.useMetric) { _,_ in triggerSaved() }
            .onChange(of: calculatorViewModel.currency) { _,_ in triggerSaved() }
            .onChange(of: calculatorViewModel.fuelPrice) { _,_ in triggerSaved() }
            .onChange(of: calculatorViewModel.fuelPriceUnit) { _,_ in triggerSaved() }
        }
    }

    private func triggerSaved() {
        withAnimation { showSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showSaved = false }
        }
    }
}

// MARK: - Subviews
extension SettingsView {
    private var weatherConfigCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.cyan)
                Text("Weather API")
                    .font(.headline)
            }

            WeatherAPIKeyEditor()
        }
        .padding(20)
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
    }
    private var vehicleConfigCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.teal)
                Text("Vehicle API")
                    .font(.headline)
            }

            VehicleAPIKeyEditor()
        }
        .padding(20)
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
    }
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
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
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
                        Text("Currently: \(calculatorViewModel.currency.name) (\(calculatorViewModel.currency.symbol))")
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
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
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
                    Text("Current: \(CurrencyFormatter.format(calculatorViewModel.fuelPrice, currencyCode: calculatorViewModel.currency.id))/\(calculatorViewModel.fuelPriceLongUnitLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Quick conversion hint (show the alternate unit)
                    if calculatorViewModel.fuelPriceUnit == .perGallon {
                        Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice / 3.78541, currencyCode: calculatorViewModel.currency.id))/L")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice * 3.78541, currencyCode: calculatorViewModel.currency.id))/gal")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(20)
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
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
                Text("1.2.1").foregroundStyle(.secondary)
            }
            .padding(12)
            .modifier(GlassCardModifier(config: .init(cornerRadius: 12)))

            HStack(spacing: 12) {
                Text("Build")
                Spacer()
                Text("2025.5").foregroundStyle(.secondary)
            }
            .padding(12)
            .modifier(GlassCardModifier(config: .init(cornerRadius: 12)))
        }
        .padding(20)
        .modifier(GlassCardModifier(config: .init(cornerRadius: 16)))
    }
}

// MARK: - Helpers
extension SettingsView {
    private var currencySymbol: String {
        calculatorViewModel.currency.symbol
    }
}

// MARK: - Weather API Key Editor
private struct WeatherAPIKeyEditor: View {
    @State private var apiKey: String = ""
    @State private var isSaved: Bool = false
    @State private var reveal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenWeatherMap API Key")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if reveal {
                    TextField("Enter API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                } else {
                    SecureField("Enter API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }

                Button {
                    reveal.toggle()
                } label: {
                    Image(systemName: reveal ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(reveal ? "Hide" : "Show")
            }

            HStack(spacing: 10) {
                Button {
                    let ok = KeychainService.shared.set(apiKey, for: "OPENWEATHER_API_KEY")
                    withAnimation { isSaved = ok }
                    if ok {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { isSaved = false }
                        }
                    }
                } label: {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    _ = KeychainService.shared.remove("OPENWEATHER_API_KEY")
                    apiKey = ""
                } label: {
                    Label("Remove", systemImage: "trash")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                if isSaved {
                    Label("Saved", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.footnote)
                        .transition(.opacity)
                }
                Spacer()
            }

            Text("Tip: You can also set OPENWEATHER_API_KEY in your Xcode Scheme (Run → Arguments → Environment Variables).")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            if let existing = KeychainService.shared.get("OPENWEATHER_API_KEY") {
                apiKey = existing
            }
        }
    }
}

// MARK: - Vehicle API Key Editor
private struct VehicleAPIKeyEditor: View {
    @State private var apiKey: String = ""
    @State private var isSaved: Bool = false
    @State private var reveal: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API Ninjas API Key")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if reveal {
                    TextField("Enter API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                } else {
                    SecureField("Enter API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                }

                Button {
                    reveal.toggle()
                } label: {
                    Image(systemName: reveal ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(reveal ? "Hide" : "Show")
            }

            HStack(spacing: 10) {
                Button {
                    let ok = KeychainService.shared.set(apiKey, for: "API_NINJAS_API_KEY")
                    withAnimation { isSaved = ok }
                    if ok {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { isSaved = false }
                        }
                    }
                } label: {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    _ = KeychainService.shared.remove("API_NINJAS_API_KEY")
                    apiKey = ""
                } label: {
                    Label("Remove", systemImage: "trash")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                if isSaved {
                    Label("Saved", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.footnote)
                        .transition(.opacity)
                }
                Spacer()
            }

            Text("Tip: You can also set API_NINJAS_API_KEY in your Xcode Scheme (Run → Arguments → Environment Variables).")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear {
            if let existing = KeychainService.shared.get("API_NINJAS_API_KEY") {
                apiKey = existing
            }
        }
    }
}
