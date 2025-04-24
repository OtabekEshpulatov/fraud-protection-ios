import SwiftUI

struct SignInView: View {
    @StateObject private var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("username".localized, text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    SecureField("password".localized, text: $password)
                        .textContentType(.password)
                }
                
                if let error = error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        Task {
                            await signIn()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("sign_in".localized)
                        }
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                }
            }
            .navigationTitle("sign_in".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func signIn() async {
        isLoading = true
        error = nil
        
        do {
            try await authService.signIn(username: username, password: password)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    SignInView()
} 