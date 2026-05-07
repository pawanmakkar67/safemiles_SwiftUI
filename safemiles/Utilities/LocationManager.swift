import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var lastLocation: CLLocation? {
        didSet {
            if let location = lastLocation {
                reverseGeocode(location)
            }
        }
    }
    @Published var currentAddress: String = ""
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // meters
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let _ = error { return }
            
            if let placemark = placemarks?.first {
                var addressParts: [String] = []
                
                if let subThoroughfare = placemark.subThoroughfare { addressParts.append(subThoroughfare) }
                if let thoroughfare = placemark.thoroughfare { addressParts.append(thoroughfare) }
                if let locality = placemark.locality { addressParts.append(locality) }
                if let administrativeArea = placemark.administrativeArea { addressParts.append(administrativeArea) }
                if let country = placemark.country { addressParts.append(country) }
                
                let addressString = addressParts.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.currentAddress = addressString
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager Error: \(error.localizedDescription)")
    }
}
