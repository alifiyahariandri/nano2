////
////  LocationManager.swift
////  Nano2
////
////  Created by Alifiyah Ariandri on 16/05/24.
////

import CoreLocation
import WeatherKit

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    typealias LocationUpdateHandler = (CLLocation?, Error?) -> Void
    private var didUpdateLocation: LocationUpdateHandler?
    
    @Published var location: CLLocationCoordinate2D?
    @Published var locationString: String?
    @Published var locationCityCountry: String?

    
    @Published var dateTime: Date = .init()
    @Published var timeZone: TimeZone?
    
    @Published var currentWeather: CurrentWeather?
    var weatherServiceHelper = WeatherData.shared

    let formatter = DateFormatter()

    @Published var formattedTime: String?
    @Published var isNight: Bool?

    
    var customLocation: CLLocation? // Add custom location property

    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
    }
    
    // New initializer to accept custom location
        init(customLocation: CLLocation?) {
            self.customLocation = customLocation
            super.init()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            manager.requestWhenInUseAuthorization()
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = customLocation?.coordinate ?? locations.first?.coordinate // Use custom location if available

        dateTime = Date()
        
        reverseGeocoding(latitude: location?.latitude ?? 0.0, longitude: location?.longitude ?? 0.0) { name in
            if let locationName = name {
                self.locationString = (locationName.name ?? "-")
                self.locationCityCountry = (locationName.locality ?? "-") + ", " + (locationName.country ?? "-")
                self.timeZone = locationName.timeZone!
                self.formatter.dateStyle = .medium
                self.formatter.timeStyle = .medium
                self.formatter.timeZone = self.timeZone
             
                self.formattedTime = self.formatter.string(from: self.dateTime)
                let index = self.formattedTime?.firstIndex(of: ".")!
                let newStr = self.formattedTime?.substring(to: index!)
                

                
                if Int(newStr ?? "0") ?? 0 < 12 {
                    self.isNight = false
                } else {
                    self.isNight = true
                }
                
                self.locationUpdated(location: CLLocation(latitude: self.location?.latitude ?? 0.0, longitude: self.location?.longitude ?? 0.0))
                
            } else {
                print("Failed to get location name.")
                self.locationString = "failed"
            }
        }
        
        if let handler = didUpdateLocation {
            handler(locations.last, nil)
        }
        manager.stopUpdatingLocation()
    }
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        let location = customLocation ?? CLLocation(latitude: latitude, longitude: longitude) // Use custom location if available

        geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if error != nil {
                print("Failed to retrieve address")
                completion(nil)
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.first {
                print(placemark.name!)
                completion(placemark)
            } else {
                print("No Matching Address Found")
                completion(nil)
            }
        })
    }
    
    func locationUpdated(location: CLLocation?) {
        if let currentLocation = location {
            Task.detached {
                if let currentLocation = location {
                    let weatherData = await self.weatherServiceHelper.currentWeather(for: currentLocation)

                    DispatchQueue.main.async { [self] in
                        self.currentWeather = weatherData
                        
                        print("PPPPPPPP" + (self.currentWeather?.symbolName ?? "yayfa"))
                    }
                }
            }
        } else {}
    }

    public func updateLocation(handler: @escaping LocationUpdateHandler) {
        didUpdateLocation = handler
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let handler = didUpdateLocation {
            handler(nil, error)
        }
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ postalCode: String?, _ city: String?, _ country: String?, _ error: Error?) -> Void) {
        return CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.postalCode, $0?.first?.locality, $0?.first?.country, $1)
        }
    }
}
