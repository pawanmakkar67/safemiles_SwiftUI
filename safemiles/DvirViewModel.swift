import SwiftUI
import Combine
import ObjectMapper
import Alamofire

class DvirViewModel: ObservableObject {
    @Published var dvirData: [DivrData] = []
    @Published var isLoading: Bool = false
    @Published var totalCount: Int = 0
    
    private var currentPage: Int = 1
    
    func fetchDivrs(refresh: Bool = false) {
        if refresh {
            currentPage = 1
            isLoading = true
        }
        
        let page = refresh ? 1 : ((dvirData.count / 10) + 1)
        let params: [String: Any] = ["page": page]
        
        print("Fetching DVIRs page: \(page)")
        
        APIManager.shared.request(url: ApiList.Divrs, method: .get, parameters: params) { [weak self] completion in
            // Handle completion if needed or just use success/failure blocks
                 DispatchQueue.main.async {
                     self?.isLoading = false
                 }
        } success: { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let obj = Mapper<DivrModel>().map(JSONObject: response) {
                    if refresh || page == 1 {
                        self.dvirData = obj.data ?? []
                    } else {
                        self.dvirData.append(contentsOf: obj.data ?? [])
                    }
                    self.totalCount = obj.total_count ?? 0
                }
            }
        } failure: { [weak self] error in
            print("DVIR fetch failed: \(String(describing: error))")
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }
    
    func loadMore() {
        if dvirData.count < totalCount && !isLoading {
            fetchDivrs(refresh: false)
        }
    }
}
