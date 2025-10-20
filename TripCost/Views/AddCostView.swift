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
            ScrollView {
                VStack(spacing: 18) {
                    categoryCard
                    amountCard
                    notesCard
                    addButton
                }
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Add Cost")
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
    }

    private func addCost() {
        guard let costAmount = Double(amount) else { return }
        let cost = AdditionalCost(category: category, amount: costAmount, notes: notes)
        calculatorViewModel.addAdditionalCost(cost)
        dismiss()
    }
}

// MARK: - Subviews
extension AddCostView {
    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "tag.fill")
                    .foregroundStyle(.orange)
                Text("Category")
                    .font(.headline)
            }
            
            Picker("Category", selection: $category) {
                ForEach(AdditionalCost.Category.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon)
                        .tag(cat)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(.blue)
                Text("Amount")
                    .font(.headline)
            }

            HStack(spacing: 10) {
                Text(currencySymbol)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                TextField("0.00", text: $amount)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.leading)
                    .onChange(of: amount) { _, newValue in
                        amount = sanitizeAmountInput(newValue)
                    }
            }

            Text("Use numbers and a decimal point only")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "note.text")
                    .foregroundStyle(.purple)
                Text("Notes (optional)")
                    .font(.headline)
            }
            
            TextField("Add any details…", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var addButton: some View {
        Button {
            addCost()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                Text("Add Cost")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
            )
            .foregroundStyle(.blue)
            .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(amount.isEmpty || Double(amount) == nil)
    }
}

// MARK: - Helpers
extension AddCostView {
    private var currencySymbol: String {
        calculatorViewModel.currency.symbol
    }
    
    private func sanitizeAmountInput(_ input: String) -> String {
        // Allow only digits and a single dot
        var result = input.filter { $0.isNumber || $0 == "." }
        let dotCount = result.filter { $0 == "." }.count
        if dotCount > 1 {
            // Keep only the first dot
            var seenDot = false
            result = result.reduce(into: "") { partial, ch in
                if ch == "." {
                    if !seenDot { partial.append(ch); seenDot = true }
                } else {
                    partial.append(ch)
                }
            }
        }
        return result
    }
}
