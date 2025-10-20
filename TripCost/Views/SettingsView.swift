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
            Form {
                // Units Section
                Section {
                    Toggle(isOn: $calculatorViewModel.useMetric) {
                        HStack(spacing: 12) {
                            Image(systemName: "ruler")
                                .foregroundStyle(.blue)
                                .font(.title3)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Metric System")
                                    .font(.body)
                                Text("Use kilometers instead of miles")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                } header: {
                    Label("Units", systemImage: "ruler.fill")
                        .font(.headline)
                }
                
                // Currency Section
                Section {
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
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Currency")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("Currently: \(calculatorViewModel.currencyCode)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Label("Currency", systemImage: "dollarsign.circle.fill")
                        .font(.headline)
                }

                // Fuel Pricing Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.orange.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "fuelpump.fill")
                                    .foregroundStyle(.orange)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fuel Price")
                                    .font(.body)
                                Text("Price per \(calculatorViewModel.useMetric ? "liter" : "gallon")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Text(CurrencyFormatter.format(0, currencyCode: calculatorViewModel.currencyCode).prefix(1))
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            
                            TextField("Price per \(calculatorViewModel.useMetric ? "liter" : "gallon")", text: $fuelPriceText)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                                .onChange(of: fuelPriceText) { _, newValue in
                                    if let price = Double(newValue) {
                                        calculatorViewModel.fuelPrice = price
                                    }
                                }
                        }
                        
                        HStack {
                            Text("Current: \(CurrencyFormatter.format(calculatorViewModel.fuelPrice, currencyCode: calculatorViewModel.currencyCode))/\(calculatorViewModel.useMetric ? "liter" : "gallon")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            // Quick conversion hint
                            if !calculatorViewModel.useMetric {
                                Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice * 3.78541, currencyCode: calculatorViewModel.currencyCode))/liter")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            } else {
                                Text("≈ \(CurrencyFormatter.format(calculatorViewModel.fuelPrice / 3.78541, currencyCode: calculatorViewModel.currencyCode))/gallon")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.leading, 52)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Fuel Pricing", systemImage: "fuelpump.fill")
                        .font(.headline)
                } footer: {
                    Text("Fuel price will be used to calculate trip costs. Price updates based on your selected unit system.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // About Section
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.purple)
                            .font(.title3)
                            .frame(width: 30)
                        
                        Text("Version")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(.purple)
                            .font(.title3)
                            .frame(width: 30)
                        
                        Text("Build")
                            .font(.body)
                        
                        Spacer()
                        
                        Text("2025.1")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle.fill")
                        .font(.headline)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .onAppear {
                fuelPriceText = String(format: "%.2f", calculatorViewModel.fuelPrice)
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $calculatorViewModel.currencyCode)
            }
        }
    }
}
