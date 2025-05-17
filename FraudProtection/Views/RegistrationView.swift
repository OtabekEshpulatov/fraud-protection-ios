import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var selectedRegion: RegionDto?
    @State private var regions: [RegionDto] = []
    
    private func validateFields() -> Bool {
        // Trim whitespace from username
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUsername.isEmpty {
            errorMessage = "error_username_required".localized
            return false
        }
        
        if password.isEmpty {
            errorMessage = "error_password_required".localized
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "error_passwords_dont_match".localized
            return false
        }
        
        if selectedRegion == nil {
            errorMessage = "error_region_required".localized
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Username", text: $username)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .onChange(of: username) { _ in
                            errorMessage = nil // Clear error when user types
                        }
                    
                    SecureField("Password", text: $password)
                        .onChange(of: password) { _ in
                            errorMessage = nil // Clear error when user types
                        }
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .onChange(of: confirmPassword) { _ in
                            errorMessage = nil // Clear error when user types
                        }
                }
                
                Section(header: Text("Region")) {
                    if regions.isEmpty {
                        ProgressView("Loading regions...")
                    } else {
                        Menu {
                            ForEach(regions) { region in
                                Button(action: {
                                    selectedRegion = region
                                    errorMessage = nil // Clear error when region is selected
                                }) {
                                    HStack {
                                        Text(getLocalizedRegionName(for: region))
                                        if selectedRegion?.id == region.id {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("Select Region")
                                Spacer()
                                if let selectedRegion = selectedRegion {
                                    Text(getLocalizedRegionName(for: selectedRegion))
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Register") {
                        if validateFields() {
                            authViewModel.register(
                                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                password: password,
                                regionId: selectedRegion?.id ?? ""
                            ) { success, message in
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    errorMessage = message ?? "error_registration_failed".localized
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section {
                    HStack {
                        Text("Already Registered?")
                        NavigationLink("Login", destination: LoginView())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Register")
            .onAppear {
                fetchRegions()
            }
        }
    }
    
    private func fetchRegions() {
        guard let url = URL(string: EnvManager.shared.require("API_URL") + APIConstants.regions) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode([RegionDto].self, from: data) else { return }
            DispatchQueue.main.async {
                self.regions = decoded
                self.selectedRegion = decoded.first
            }
        }.resume()
    }
    
    private func getLocalizedRegionName(for region: RegionDto) -> String {
        let currentLocale = LanguageManager.shared.currentLanguage.rawValue
        return region.names.first(where: { $0.locale == currentLocale })?.name ?? region.names.first?.name ?? "Unknown"
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AuthViewModel.shared)
}
