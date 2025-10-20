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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Toggle("Use Metric (km)", isOn: $calculatorViewModel.useMetric)
                }

                Section("Fuel Pricing") {
                    HStack {
                        Text("$").foregroundStyle(.secondary)
                        TextField("Price per gallon", text: $fuelPriceText)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: fuelPriceText) { _, newValue in
                                if let price = Double(newValue) {
                                    calculatorViewModel.fuelPrice = price
                                }
                            }
                    }
                    Text("Current: \(CurrencyFormatter.format(calculatorViewModel.fuelPrice))/gallon")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .onAppear {
                    fuelPriceText = String(format: "%.2f", calculatorViewModel.fuelPrice)
                }


                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "2025.1")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                fuelPriceText = String(format: "%.2f", calculatorViewModel.fuelPrice)
            }
        }
    }
}
