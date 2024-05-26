//
//  Nano2App.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 16/05/24.
//

import SwiftUI
import CoreLocation

@main
struct Nano2App: App {
//    @StateObject var locationManager = LocationManager()
    let customLocation = CLLocation(latitude: 20, longitude: 20)
    
    var body: some Scene {
        WindowGroup {
//            CurrentWeatherView()
            HomeView()
//            MapView()
//            PetSunscreenView()
//                .environmentObject(locationManager)
//                .ignoresSafeArea()
//            CustomLocation(customLocation: customLocation)
        }
    }
}
