//
//  CostSplitView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct CostSplitView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var calculatorViewModel: TripCalculatorViewModel
    @Bindable var vehicleViewModel: VehicleViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                totalCostDisplay
                peopleSelector
                splitBreakdown
                Spacer()
            }
            .padding()
            .navigationTitle("Split Cost")
            // macOS: no navigationBarTitleDisplayMode
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .font(.title3)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private var totalCostDisplay: some View {
        VStack(spacing: 8) {
            Text("Total Cost")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(CurrencyFormatter.format(calculatorViewModel.tripCost(vehicle: vehicleViewModel.selectedVehicle)?.totalCost ?? 0, currencyCode: calculatorViewModel.currency.id))
                .font(.system(size: 36, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    private var peopleSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of People")
                .font(.headline)

            HStack(spacing: 16) {
                Button {
                    if calculatorViewModel.numberOfPeople > 1 {
                        withAnimation(AnimationConstants.spring) {
                            calculatorViewModel.numberOfPeople -= 1
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(calculatorViewModel.numberOfPeople > 1 ? .blue : .gray)
                }
                .disabled(calculatorViewModel.numberOfPeople <= 1)

                Text("\(calculatorViewModel.numberOfPeople)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(minWidth: 80)
                    .contentTransition(.numericText())

                Button {
                    withAnimation(AnimationConstants.spring) {
                        calculatorViewModel.numberOfPeople += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var splitBreakdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cost Per Person")
                .font(.headline)

            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
                Text("Each person pays")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(CurrencyFormatter.format(calculatorViewModel.totalCostPerPerson(vehicle: vehicleViewModel.selectedVehicle), currencyCode: calculatorViewModel.currency.id))
                    .font(.title3)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .padding()
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
