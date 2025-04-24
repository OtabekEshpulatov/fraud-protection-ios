import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("welcome_back".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("username".localized, text: $viewModel.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("password".localized, text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("login".localized)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                NavigationLink(destination: RegistrationView(), isActive: $showRegistration) {
                    Button("dont_have_account".localized) {
                        showRegistration = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
} 
