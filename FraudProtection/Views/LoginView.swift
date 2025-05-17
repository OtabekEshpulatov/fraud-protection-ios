//
//  LoginView.swift
//  FraudProtection
//
//  Created by kebato OS on 05/05/25.
//


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
            Form  {
                TextField("Username", text: $username)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none) // For iOS 14 and earlier

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
                }.frame(maxWidth: .infinity)
                    .padding()
                
                Section {
                    HStack {
                        Text("Not registered?")
                        HStack {
                            Button{
                                
                            }label: {
                                Text("Register")
                            }
                        
                        }
                        .background(
                            NavigationLink(destination: RegistrationView()) {
                                EmptyView()
                            }
                            .opacity(0)
                        )
                    }.frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Login")
            
            
        }
    }
}

#Preview {
    LoginView()
}
