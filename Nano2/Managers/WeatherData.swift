//
//  WeatherData.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 19/05/24.
//

import CoreLocation
import Foundation
import os
import WeatherKit

class WeatherData: ObservableObject {
    let logger = Logger(subsystem: "com.test.Nano2", category: "Model")
    static let shared = WeatherData()
    private let service = WeatherService.shared

    func currentWeather(for location: CLLocation) async -> CurrentWeather? {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: location,
                including: .current)
            return forecast
        }.value
        return currentWeather
    }
}
