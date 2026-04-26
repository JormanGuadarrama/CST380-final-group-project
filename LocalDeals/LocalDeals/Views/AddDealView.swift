//
//  AddDealView.swift
//  LocalDeals
//
//  Empty form for submitting a new deal — title, description, location, expiration.
//

import SwiftUI

struct AddDealView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var locationText: String = ""
    @State private var expiration: Date = Date()
    @State private var discountType: String = "Percent Off"

    private let discountTypes = ["Percent Off", "Dollar Off", "BOGO", "Other"]

    private func resetForm() {
        title = ""
        description = ""
        locationText = ""
        expiration = Date()
        discountType = "Percent Off"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Deal Info") {
                    TextField("Title (e.g. $5 Off Margarita Flights)", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Location") {
                    TextField("Address or business name", text: $locationText)
                    // TODO: replace with map picker / GPS
                    Button(action: { /* TODO: open map picker */ }) {
                        Label("Pick on Map", systemImage: "map")
                    }
                }

                Section("Discount") {
                    Picker("Type", selection: $discountType) {
                        ForEach(discountTypes, id: \.self) { Text($0) }
                    }
                }

                Section("Expiration") {
                    DatePicker("Expires", selection: $expiration, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        // TODO: submit to backend (#6)
                        resetForm()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDealView()
}
