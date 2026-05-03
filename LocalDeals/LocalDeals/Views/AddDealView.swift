import SwiftUI
import CoreLocation

struct AddDealView: View {
    @Environment(DealManager.self) var dealManager
    @Environment(AuthManager.self) var authManager

    var onFinish: (() -> Void)? = nil

    @State private var locationManager = LocationManager()

    @State private var title: String = ""
    @State private var businessName: String = ""
    @State private var description: String = ""
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    @State private var expiration: Date = Date().addingTimeInterval(60 * 60 * 24)
    @State private var discountType: String = "Percent Off"
    @State private var imageUrl: String = ""

    @State private var showMapPicker = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?

    private let discountTypes = ["Percent Off", "Dollar Off", "BOGO", "Other"]

    private func resetForm() {
        title = ""
        businessName = ""
        description = ""
        latitudeText = ""
        longitudeText = ""
        expiration = Date().addingTimeInterval(60 * 60 * 24)
        discountType = "Percent Off"
        imageUrl = ""
        selectedCoordinate = nil
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !latitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !longitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Deal Info") {
                    TextField("Title", text: $title)
                    TextField("Business Name", text: $businessName)
                    TextField("Description", text: $description, axis: .vertical)
                }

                Section("Location") {
                    TextField("Latitude", text: $latitudeText)
                        .keyboardType(.decimalPad)

                    TextField("Longitude", text: $longitudeText)
                        .keyboardType(.decimalPad)

                    Button {
                        print("[AddDealView] Map picker opened")
                        showMapPicker = true
                    } label: {
                        Label("Pick on Map", systemImage: "map")
                    }

                    if let selectedCoordinate {
                        Text("Selected: \(selectedCoordinate.latitude), \(selectedCoordinate.longitude)")
                            .font(.caption)
                    }
                }

                Section("Discount") {
                    Picker("Type", selection: $discountType) {
                        ForEach(discountTypes, id: \.self) { Text($0) }
                    }
                }

                Section("Expiration") {
                    DatePicker("Expires", selection: $expiration, in: Date()..., displayedComponents: .date)
                }

                Section("Image") {
                    TextField("Image URL", text: $imageUrl)
                }
            }
            .navigationTitle("Add Deal")
            .toolbar {

                // CANCEL
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        print("[AddDealView] Cancel tapped.")
                        resetForm()
                        onFinish?()
                    }
                }

                // SUBMIT
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        print("[AddDealView] Submit tapped. Form valid: \(isFormValid)")

                        guard isFormValid,
                              let latitude = Double(latitudeText),
                              let longitude = Double(longitudeText),
                              let uid = authManager.userID,
                              let email = authManager.userEmail else {
                            print("[AddDealView] Validation failed")
                            return
                        }

                        Task {
                            print("[AddDealView] Sending deal to Firestore...")

                            await dealManager.addDeal(
                                title: title,
                                businessName: businessName,
                                description: description,
                                discountType: discountType,
                                expiration: expiration,
                                imageUrl: imageUrl,
                                latitude: latitude,
                                longitude: longitude,
                                createdByUid: uid,
                                createdByEmail: email
                            )

                            print("[AddDealView] Deal successfully added. Resetting form.")

                            resetForm()
                            onFinish?()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showMapPicker) {
                MapPickerView { coordinate in
                    print("[AddDealView] Map location selected: \(coordinate)")
                    selectedCoordinate = coordinate
                    latitudeText = String(coordinate.latitude)
                    longitudeText = String(coordinate.longitude)
                }
                .environment(locationManager)
            }
        }
    }
}
