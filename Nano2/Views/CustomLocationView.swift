//
//  CustomLocationView.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 25/05/24.
//

import CoreLocation
import MapKit
import SpriteKit
import SwiftUI
import WeatherKit

struct CustomLocation: View {
    @State var currentWeather: CurrentWeather?
    
    @State var isSunscreen: Bool = false
    
    var weatherServiceHelper = WeatherData.shared
    
    var customLocation: CLLocation
    @ObservedObject var locationManager: LocationManager
        
    init(customLocation: CLLocation) {
        self.customLocation = customLocation
        self._locationManager = ObservedObject(wrappedValue: LocationManager(customLocation: customLocation))
    }
 
    var body: some View {
        NavigationStack {
            ZStack {
                if locationManager.currentWeather?.isDaylight ?? false {
                    Image("wallpaper-day")
                } else {
                    Image("wallpaper-night")
                }
                
                if let current = currentWeather {
                    if current.condition.description == "Clear" {
                        SpriteView(scene: Fall(fileName: "Clear.sks"), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Haze") || current.condition.description.contains("Fog") {
                        SpriteView(scene: Fall(fileName: "Haze.sks"), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Rain") {
                        SpriteView(scene: Fall(fileName: "RainFall.sks"), options: [.allowsTransparency])
                            .edgesIgnoringSafeArea(.all) // Make sure it covers the whole screen
                    } else if current.condition.description.contains("Cloudy") {
                        SpriteView(scene: Slide(fileName: "Cloudy.sks"), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Windy") {
                        SpriteView(scene: Slide(fileName: "Wind.sks"), options: [.allowsTransparency])
                    }
                        
                    Image(systemName: current.symbolName)
                        .font(.system(size: 75.0, weight: .bold))
                        
                    Text(current.condition.description)
                        .font(Font.system(.largeTitle))
                        
                    let tUnit = current.temperature.unit.symbol
                    Text("\(current.temperature.value.formatted(.number.precision(.fractionLength(1))))\(tUnit)")
                        .font(Font.system(.title))
                        
                    if isSunscreen {
                        PetSunscreenView(isSunscreen: self.$isSunscreen).frame(width: 350, height: 460).offset(y: 50)

                    } else if current.condition.description.contains("Rain") {
                        Image("chara-cold")
                            .offset(y: 50)
                            .animation(.bouncy)
                    } else {
                        Image("chara")
                            .offset(y: 50)
                            .animation(.bouncy)
                    }
                    VStack(alignment: .leading) {
                        Text("Feels like: \(locationManager.currentWeather?.temperature.value.formatted(.number.precision(.fractionLength(1))) ?? "-") \(tUnit)")
                            .font(Font.system(.title2))
                        Text("Humidity: \((current.humidity * 100).formatted(.number.precision(.fractionLength(1))))%")
                            .font(Font.system(.title2))
                        Text("Wind Speed: \(Int(current.wind.speed.value)), \(current.wind.compassDirection.description)")
                            .font(Font.system(.title2))
                        Text("UV Index: \(current.uvIndex.value)")
                            .font(Font.system(.title2))
                    }
                }
                
                VStack {
                    Spacer().frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    HStack {
                        ZStack {
                            Image("coin-frame")
                            Text("300")
                                .font(Font.custom("PottaOne-Regular", size: 36))
                                .foregroundColor(.white)
                                .offset(x: 40)
                        }
                        Spacer()
                            .frame(width: 450)

                        NavigationLink(
                            destination: MapView(region: MKCoordinateRegion(
                                center: customLocation.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                            )),
                            label: {
                                Image("map")
                            }
                        )
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        
                        NavigationLink(
                            destination: HomeView(),
                            label: {
                                Image("home")
                            }
                        )
                        
                        Spacer().frame(width: 75)
                    }
                    
                    Spacer().frame(height: 75)
                }
                
                VStack {
                    Spacer().frame(height: 200)
                    
                    Text("\(locationManager.locationString ?? "Not Found")")
                        .font(Font.custom("PottaOne-Regular", size: 36))
                        .foregroundColor(.white)
                    
                    Text("\(locationManager.locationCityCountry ?? "Not Found")")
                        .font(Font.custom("PottaOne-Regular", size: 28))
                        .foregroundColor(.white)
                        
                    HStack {
                        Text("Last update: \(locationManager.formattedTime ?? "Loading...") (\(locationManager.timeZone?.identifier ?? "Loading..."))")
                            .font(Font.custom("Poppins-Regular", size: 18)).foregroundColor(.white)
                        Button {
                            self.locationManager.updateLocation(handler: locationUpdated)
                        } label: {
                            Image(systemName: "arrow.clockwise").foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                }
                VStack {
                    if let current = currentWeather {
                        Image(systemName: current.symbolName)
                            .font(.system(size: 75.0, weight: .bold))
                        
                        Text(current.condition.description)
                            .font(Font.system(.largeTitle))
                        
                        let tUnit = current.temperature.unit.symbol
                        Text("\(current.temperature.value.formatted(.number.precision(.fractionLength(1))))\(tUnit)")
                            .font(Font.system(.title))
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Feels like: \(locationManager.currentWeather?.temperature.value.formatted(.number.precision(.fractionLength(1))) ?? "-") \(tUnit)")
                                .font(Font.system(.title2))
                            Text("Humidity: \((current.humidity * 100).formatted(.number.precision(.fractionLength(1))))%")
                                .font(Font.system(.title2))
                            Text("Wind Speed: \(Int(current.wind.speed.value)), \(current.wind.compassDirection.description)")
                                .font(Font.system(.title2))
                            Text("UV Index: \(current.uvIndex.value)")
                                .font(Font.system(.title2))
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            self.isSunscreen.toggle()
                        } label: {
                            ZStack {
                                Image("button")
                                Image("sunscreen")
                                if self.isSunscreen {
                                    Rectangle().frame(width: 150, height: 150).foregroundColor(.black).opacity(0.5).cornerRadius(50)
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 150)
                }
            }
            .task {
                self.locationManager.updateLocation(handler: locationUpdated)
            }
        }.navigationBarBackButtonHidden()
    }
    
    func locationUpdated(location: CLLocation?, error: Error?) {
        if let _ = location, error == nil {
            Task.detached {
                if let _ = location {
                    let weatherData = await weatherServiceHelper.currentWeather(for: customLocation)

                    DispatchQueue.main.async { [self] in
                        self.currentWeather = weatherData
                    }
                }
            }
        }
    }
}

struct CustomLocation_Preview: PreviewProvider {
    static var previews: some View {
        let location = CLLocation(latitude: 51.5074, longitude: -0.1278) // London coordinates
        
        return CustomLocation(customLocation: location)
            .previewDisplayName("Custom Location Preview")
    }
}
