import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    static var shared: LocationManager!

    @Published var currentCountry: String = ""
    @Published var currentState: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        if LocationManager.shared == nil {
            LocationManager.shared = self
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }

    func checkLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    return
                }

                guard let placemark = placemarks?.first else {
                    print("No placemark found.")
                    return
                }

                if let country = placemark.country {
                    self.currentCountry = country
                }

                if let state = placemark.administrativeArea {
                    self.currentState = state
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
