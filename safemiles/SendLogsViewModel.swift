
import SwiftUI
import Combine
import Alamofire
import ObjectMapper

class SendLogsViewModel: ObservableObject {
    @Published var transferType: String = "Email"
    @Published var comment: String = ""
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showSuccessInfo = false
    
    // Options for the picker
    // Reference code had ["PDF", "HTML"] but screenshot shows "Email".
    // "Email" and "Web Services" are standard ELD transfer types for "Send Logs" to FMCSA.
    // However, if the user intends strictly "PDF/HTML" export as per ref code, we might need to adjust.
    // Given usage of ApiList.sendLogs (usually FMCSA transfer), "Email" and "Web Services" are likely correct.
    // But adhering to the screenshot showing "Email", I'll provide that. 
    // I will include "Web Services" as the other standard option.
    let transferOptions = ["Email", "Web Services"]
    
    func sendLogs(onSuccess: @escaping () -> Void) {
        if transferType.isEmpty {
            alertMessage = "Please select a transfer type."
            return
        }
        
        isLoading = true
        let params: [String: Any] = [
            "transfer_type": transferType,
            "comment": comment
        ]
        
        APIManager.shared.request(url: ApiList.sendLogs, method: .post, parameters: params) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Handle success - maybe show alert or just callback
                // Ref code pops to previous.
                // We'll trigger callback
                onSuccess()
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.alertMessage = error ?? "Unknown error occurred"
            }
        }
    }
}
