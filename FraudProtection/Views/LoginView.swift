// ... existing code ...
// FraudProtection/Views/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
                if let errorMessage = errorMessage {
                    Text(errorMessage).foregroundColor(.red)
                }
                Button("Login") {
                    authViewModel.login(username: username, password: password) { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            errorMessage = "Login failed. Please check your credentials."
                        }
                    }
                }
            }
            .navigationTitle("Login")
        }
    }
}