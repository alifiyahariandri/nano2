//
//  WeatherManager.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 18/05/24.
//
//
//import Foundation
//import WeatherKit
//import CoreLocation
//import os
//
//@MainActor
//class WeatherManager: ObservableObject {
////    static let shared = WeatherManager()
//    private let service = WeatherService.shared
//
//    var latitude = 0.0
//    var longitude = 0.0
//
//    var location: CLLocation {
//        CLLocation(latitude: latitude, longitude: longitude)
//    }
//
//    var date: Date
//    var condition: String
//    var symbolName: String
//    var temperature: Temperature
//    var precipitation: String
//    var precipitationChance: Double
//    var windSpeed: Measurement<UnitSpeed>
//
//    var isDailyForecast: Bool {
//        temperature.isDaily
//    }
//
//    var isHourlyForecast: Bool {
//        !temperature.isDaily
//    }
//
//    init(_ forecast: DayWeather) {
//
//        date = forecast.date
//        condition = forecast.condition.description
//        symbolName = forecast.symbolName
//        temperature = .daily(
//            high: forecast.highTemperature,
//            low: forecast.lowTemperature)
//        precipitation = forecast.precipitation.description
//        precipitationChance = forecast.precipitationChance
//        windSpeed = forecast.wind.speed
//    }
//
//    init(_ forecast: HourWeather) {
//        date = forecast.date
//        condition = forecast.condition.description
//        symbolName = forecast.symbolName
//        temperature = .hourly(forecast.temperature)
//        precipitation = forecast.precipitation.description
//        precipitationChance = forecast.precipitationChance
//        windSpeed = forecast.wind.speed
//    }
//}
//
//extension WeatherManager {
//    enum Temperature {
//        typealias Value = Measurement<UnitTemperature>
//
//        case daily(high: Value, low: Value)
//        case hourly(Value)
//
//        var isDaily: Bool {
//            switch self {
//            case .daily:
//                return true
//            case .hourly:
//                return false
//            }
//        }
//    }
//
//    @discardableResult
//    func weather() async -> CurrentWeather? {
//        let currentWeather = await Task.detached(priority: .userInitiated) {
//            let forcast = try? await self.service.weather(
//                for: self.location,
//                including: .current)
//            return forcast
//        }.value
//        return currentWeather
//    }
//
//    @discardableResult
//    func dailyForecast() async -> Forecast<DayWeather>? {
//        let dayWeather = await Task.detached(priority: .userInitiated) {
//            let forcast = try? await self.service.weather(
//                for: self.location,
//                including: .daily)
//            return forcast
//        }.value
//        return dayWeather
//    }
//
//    @discardableResult
//    func hourlyForecast() async -> Forecast<HourWeather>? {
//        let hourWeather = await Task.detached(priority: .userInitiated) {
//            let forcast = try? await self.service.weather(
//                for: self.location,
//                including: .hourly)
//            return forcast
//        }.value
//        return hourWeather
//    }
//}

import Foundation
import WeatherKit

@Observable class WeatherManager {
    private let weatherService = WeatherService()
    var weather: Weather?
    
    func getWeather(lat: Double, long: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) { [weak self] in
                return try await self?.weatherService.weather(for: .init(latitude: lat, longitude: long))
            }.value
            
        } catch {
            print("Failed to get weather data. \(error)")
        }
    }
    
    func getHourlyForecast(lat: Double, long: Double) async {
        do {
            let hourWeather = try await Task.detached(priority: .userInitiated) { [weak self] in
                return try await self?.weatherService.weather(for: .init(latitude: lat, longitude: long), including: .hourly)
            }.value
            
            print(hourWeather)
            print("AAAAAAAAAAAAAAAAAAAAAAAAA")
        } catch {
            print("Failed to get weather data. \(error)")
        }
    }
    
    var icon: String {
        guard let iconName = weather?.currentWeather.symbolName else { return "--" }
        
        return iconName
    }
    
    var temperature: String {
        guard let temp = weather?.currentWeather.temperature else { return "--" }
        let convert = temp.converted(to: .celsius).value
        
        return String(Int(convert)) + "°C"
    }
    
    var humidity: String {
        guard let humidity = weather?.currentWeather.humidity else { return "--" }
        let computedHumidity = humidity * 100
        
        return String(Int(computedHumidity)) + "%"
    }
}
