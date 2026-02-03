
import SwiftUI
import Combine
import ObjectMapper
import Alamofire

class CoDriverViewModel: ObservableObject {
    @Published var coDrivers: [CoDriverData] = []
    @Published var selectedCoDriver: CoDriverData?
    @Published var isLoading = false
    @Published var errorMsg: String?
    @Published var shouldLogout = false
    
    init() {
        self.coDrivers = Global.shared.coDriverList ?? []
    }
    
    func selectCoDriver(_ driver: CoDriverData) {
        selectedCoDriver = driver
    }
    
    func switchDriver() {
        guard let driverID = selectedCoDriver?.id else {
            self.errorMsg = "Please select a co-driver"
            return
        }
        
        isLoading = true
        let param = ["driver": driverID]
        
        APIManager.shared.request(url: ApiList.getCoDrivers, method: .post, parameters: param) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                let obj = Mapper<CoDriverModel>().map(JSONObject: response)
                // Proceed to logout or state change as per requirement
                self?.shouldLogout = true
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMsg = error 
            }
        }
    }
    
    // Simulate Logout or use the same logic as MoveToController.sharedInstance.logOut(self)
    // In SwiftUI, we might just flag state change for the App Coordinator to handle
    func performLogout() {
        UserDefaults.removeAllKeys()
    }
}
