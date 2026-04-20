import SwiftUI

struct AddDealView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var businessName: String = ""
    @State private var description: String = ""
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    @State private var expiration: Date = Date()
    @State private var discountType: String = "Percent Off"
    @State private var imageUrl: String = ""

    private let discountTypes = ["Percent Off", "Dollar Off", "BOGO", "Other"]

    var body: some View {
        Form {
            Section("Deal Info") {
                TextField("Title (e.g. $5 Off Margarita Flights)", text: $title)
                TextField("Business Name", text: $businessName)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Location") {
                TextField("Latitude", text: $latitudeText)
                    .keyboardType(.decimalPad)

                TextField("Longitude", text: $longitudeText)
                    .keyboardType(.decimalPad)

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

            Section("Image") {
                TextField("Image URL (optional)", text: $imageUrl)
            }
        }
        .navigationTitle("Add Deal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Submit") {
                    guard
                        let latitude = Double(latitudeText),
                        let longitude = Double(longitudeText)
                    else {
                        print("Invalid latitude or longitude")
                        return
                    }

                    dealManager.addDeal(
                        title: title,
                        businessName: businessName,
                        description: description,
                        discountType: discountType,
                        expiration: expiration,
                        imageUrl: imageUrl,
                        latitude: latitude,
                        longitude: longitude
                    )

                    dismiss()
                }
                .disabled(
                    title.isEmpty ||
                    businessName.isEmpty ||
                    description.isEmpty ||
                    latitudeText.isEmpty ||
                    longitudeText.isEmpty
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddDealView()
            .environment(DealManager(isMocked: true))
    }
}
