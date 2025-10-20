//
//  AddCostView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI

struct AddCostView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var calculatorViewModel: TripCalculatorViewModel

    @State private var category: AdditionalCost.Category = .food
    @State private var amount = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Cost Details") {
                    Picker("Category", selection: $category) {
                        ForEach(AdditionalCost.Category.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                    HStack {
                        Text("$").foregroundStyle(.secondary)
                        TextField("Amount", text: $amount)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section {
                    Button("Add Cost") { addCost() }
                        .frame(maxWidth: .infinity)
                        .disabled(amount.isEmpty || Double(amount) == nil)
                }
            }
            .navigationTitle("Add Cost")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addCost() {
        guard let costAmount = Double(amount) else { return }
        let cost = AdditionalCost(category: category, amount: costAmount, notes: notes)
        calculatorViewModel.addAdditionalCost(cost)
        dismiss()
    }
}
