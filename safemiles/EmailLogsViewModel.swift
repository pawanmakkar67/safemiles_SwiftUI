
import SwiftUI
import Combine
import Alamofire
import ObjectMapper

class EmailLogsViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var alertMessage: String?
    
    func sendEmail(onSuccess: @escaping () -> Void) {
        if email.isEmpty || !isValidEmail(email) {
            alertMessage = "Please enter a valid email address."
            return
        }
        
        isLoading = true
        let params: [String: Any] = ["recipient_email": email]
        
        APIManager.shared.request(url: ApiList.sendEmail, method: .post, parameters: params) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Handle success
                onSuccess()
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.alertMessage = error ?? "Failed to send email."
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
