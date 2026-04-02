
import SwiftUI
import Combine
import Alamofire
import ObjectMapper

class SendLogsViewModel: ObservableObject {
    @Published var transferType: String = "Email"
    @Published var comment: String = ""
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var isSuccess = false
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
        
        if comment.isEmpty {
            alertMessage = "Please enter a comment."
            return
        }
        
        isLoading = true
        let method = (transferType == "Web Services") ? "web" : transferType.lowercased()
        let params: [String: Any] = [
            "method": method,
            "comment": comment
        ]
        
        APIManager.shared.request(url: ApiList.sendLogs, method: .post, parameters: params) { [weak self] completion in
            // Extract uncertified dates if present in the raw response
            if let response = completion as? AFDataResponse<Any>,
               let dict = response.value as? [String: Any],
               let uncertifiedDates = dict["uncertified_dates"] as? [String],
               !uncertifiedDates.isEmpty {
                let datesString = uncertifiedDates.joined(separator: ", ")
                let baseMessage = dict["message"] as? String ?? dict["error"] as? String ?? "Please certify the logs before generating the ELD file."
                
                DispatchQueue.main.async {
                    self?.alertMessage = "\(baseMessage)\nUncertified dates: \(datesString)"
                }
            }
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isSuccess = true
                self?.alertMessage = "message successfully sent"
                onSuccess()
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Only set alertMessage if it hasn't been set by completionCallback for dates
                if self?.alertMessage == nil || !(self?.alertMessage?.contains("Uncertified dates") ?? false) {
                    self?.alertMessage = error ?? "Unknown error occurred"
                }
            }
        }
    }
}
