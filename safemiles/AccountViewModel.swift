
import SwiftUI
import Combine
import ObjectMapper
import Alamofire

class AccountViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var phone: String = ""
    @Published var license: String = ""
    @Published var carrier: String = ""
    @Published var officeAddress: String = ""
    @Published var terminalAddress: String = ""
    //@Published var timezone: String = "" // Screenshot doesn't show timezone but legacy had it. Screenshot has home terminal address with city/state/zip which might imply timezone context or just location. I will stick to screenshot fields.
    // Actually screenshot has "Home Terminal Address". Legacy had "Timezone". I will follow screenshot primarily but keep data available.
    
    @Published var isLoading = false
    
    init() {
        if let profile = Global.shared.myProfile {
            updateData(profile)
        }
        fetchProfile()
    }
    
    func fetchProfile() {
        isLoading = true
        APIManager.shared.request(url: ApiList.getMyprofile, method: .get) { [weak self] _ in
            
        } success: { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let obj = Mapper<ProfileModel>().map(JSONObject: response) {
                    Global.shared.myProfile = obj.data
                    if let data = obj.data {
                        self?.updateData(data)
                    }
                }
            }
        } failure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("Error fetching profile: \(String(describing: error))")
            }
        }
    }
    
    private func updateData(_ profile: ProfileData) {
        self.email = profile.user?.email ?? profile.user?.username ?? ""
        self.name = "\(profile.user?.first_name ?? "") \(profile.user?.last_name ?? "")".trimmingCharacters(in: .whitespaces)
        self.phone = profile.phone ?? ""
        self.license = profile.license_number ?? ""
        self.carrier = profile.sim_card ?? "" // Legacy code used sim_card for carrier label
        self.officeAddress = profile.home_terminal_addr?.city ?? "" // Legacy used city for Office Address
        self.terminalAddress = getAddress(profile.home_terminal_addr)
        //self.timezone = profile.home_terminal_addr?.time_zone ?? ""
    }
    
    private func getAddress(_ addr: home_terminal_Address?) -> String {
        guard let addr = addr else { return "" }
        var address = ""
        if let line = addr.address_line, !line.isEmpty { address += line }
        if let city = addr.city, !city.isEmpty {
            address += (address.isEmpty ? "" : ", ") + city
        }
        if let state = addr.state, !state.isEmpty {
            address += (address.isEmpty ? "" : ", ") + state
        }
        if let country = addr.country, !country.isEmpty {
             // Legacy code appended country. Screenshot shows "Carson City, NV 89706" which implies simplistic formatting.
             // I'll stick to legacy logic mostly but clean spacing.
             address += (address.isEmpty ? "" : " ") + country
        }
        if let zip = addr.postal_code, !zip.isEmpty {
            address += (address.isEmpty ? "" : " ") + zip
        }
        return address
    }
}
