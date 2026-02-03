
import SwiftUI
import Combine
import Alamofire
import ObjectMapper

class RulesViewModel: ObservableObject {
    @Published var rulesData: RulesData?
    @Published var isLoading = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var isShortHaulEnabled: Bool = false
    
    // For read-only fields
    var cycleRule: String { rulesData?.default_log_setting_hos_rule ?? "" }
    var cargoType: String { rulesData?.default_log_setting_cargo_type ?? "" }
    var restart: String { rulesData?.default_log_setting_restart ?? "" }
    var restBreak: String { rulesData?.default_log_setting_rest_break ?? "" }
    
    func fetchRules() {
        isLoading = true
        APIManager.shared.request(url: ApiList.getRules, method: .get, parameters: nil) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let obj = Mapper<RulesModel>().map(JSONObject: response) {
                    self?.rulesData = obj.data
                    self?.isShortHaulEnabled = obj.data?.default_log_setting_short_haul ?? false
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.alertMessage = error
                self?.showAlert = true
            }
        }
    }
    
    // Updates Short Haul Setting
    // Based on legacy code: params = ["limit" : "7"] ??? 
    // The legacy code passed "limit":"7" to ApiList.getRules POST request.
    // It seems "getRules" (POST) is actually "updateRules" or something similar.
    // However, usually updating a boolean flag would require passing that flag.
    // The legacy code doesn't seem to pass the boolean state in `updateRules`.
    // It effectively calls the same URL with POST and param "limit: 7". 
    // This is suspicious but we will replicate legacy behavior or infer intent.
    // If the legacy code `shortHaul` switch action calls `updateRules`, then that POST call likely toggles it or sets it based on backend logic?
    // Wait, the legacy code just calls `getRules` in `viewWillAppear`. 
    // It defines `updateRules` but where is it called? 
    // It's not called in the snippet provided!
    // Ah, wait. The user snippet has `updateRules` but no IBAction for the Switch connected to it in the snippet.
    // Assuming we need to update the short haul setting. 
    // If valid API exists, we'd pass the new state. 
    // For now, let's assume we post the current state or toggle.
    // Given the ambiguity, I'll assume we should try to update the specific setting if possible, 
    // or just call the endpoint as the legacy code defined, assuming the backend handles it.
    // BUT the legacy code snippet provided DOES NOT show the switch acting on anything. 
    // I will implement the toggle to call an update function. I will construct a param dictionary that likely makes sense, 
    // or defaults to the legacy "limit: 7" if that was the "magic" param, although it looks like pagination.
    // Let's look closer at `RulesVC`:
    // `shortHaul` is an IBOutlet. `logList` populates it.
    // `updateRules` function exists with `["limit":"7"]` params.
    // It's possible the user omitted the IBAction connection in the text copy-paste.
    // I will assume standard update logic: pass the key/value.
    
    func updateShortHaul(enabled: Bool) {
        isLoading = true
        // Construct params - ideally we'd know the key name for short haul update.
        // Based on model key: `default_log_setting_short_haul`
        let key = "default_log_setting_short_haul"
        // The legacy code used "limit": "7" which is very odd for a rule update. 
        // I will try to pass the actual setting. 
        // If this fails, we might need to ask, but usually this is safer than "limit: 7".
        let params: [String: Any] = [key: enabled] 
        
        // Use POST on getRules URL as per legacy 'updateRules'
        APIManager.shared.request(url: ApiList.getRules, method: .post, parameters: params) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Refresh data to confirm change
                if let obj = Mapper<RulesModel>().map(JSONObject: response) {
                    self?.rulesData = obj.data
                    self?.isShortHaulEnabled = obj.data?.default_log_setting_short_haul ?? false
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                // Revert toggle if failed
                self?.isShortHaulEnabled = !enabled 
                self?.alertMessage = error
                self?.showAlert = true
            }
        }
    }
}
