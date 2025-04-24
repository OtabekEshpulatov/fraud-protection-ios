import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("create_account".localized)
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
                    await viewModel.register()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("register".localized)
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
            
            Button("already_have_account".localized) {
                dismiss()
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    RegistrationView()
} 