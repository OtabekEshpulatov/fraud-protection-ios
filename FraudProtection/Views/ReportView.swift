import SwiftUI

struct ReportView: View {
    
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Submitting report...")
                    .padding()
            } else {
                Form {
                    TextField("Title", text: $viewModel.title)
                    TextField("Body", text: $viewModel.body)
                    TextField("Region ID", text: $viewModel.regionId)
                    
                    Button("Select Media") {
                        // Logic to allow user to select a file
                    }
                    
                    Button("Submit Report") {
                        if AuthViewModel.shared.isAuthenticated {
                            viewModel.reportIncident()
                        } else {
                            // Navigate to login view
                            // For example: navigateToLogin()
                        }
                    }
                }
                .alert(item: $viewModel.errorMessage) { errorMessage in
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                .alert(item: $viewModel.successMessage) { successMessage in
                    Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationTitle("Report Incident")
        .padding()
    }
}
