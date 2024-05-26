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
    @State var isBouncing: Bool = false
    
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
                if let current = currentWeather {
                    if current.isDaylight {
                        Image("wallpaper-day")
                        
                        VStack {
                            HStack {
                                ZStack {
                                    if current.uvIndex.category.rawValue == "low" {
                                        Image("low")
                                    } else if current.uvIndex.category.rawValue == "moderate" {
                                        Image("mod")
                                    } else if current.uvIndex.category.rawValue == "high" {
                                        Image("high")
                                    } else if current.uvIndex.category.rawValue == "veryHigh" {
                                        Image("very high")
                                    } else {
                                        Image("extreme")
                                    }
                                    
                                    Text("\(current.uvIndex.value)").font(Font.custom("PottaOne-Regular", size: 36)).foregroundColor(.white)
                                }
                                
                                Spacer().frame(width: 600)
                            }
                            
                            Spacer().frame(height: 900)
                        }
                        
                    } else {
                        Image("wallpaper-night")
                    }
                    
                    if current.condition.description.contains("Clear") {
                        SpriteView(scene: ParticleScene(fileName: "Clear.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Haze") || current.condition.description.contains("Fog") {
                        SpriteView(scene: ParticleScene(fileName: "Haze.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Rain") {
                        SpriteView(scene: ParticleScene(fileName: "RainFall.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                            .edgesIgnoringSafeArea(.all)
                    } else if current.condition.description.contains("Cloudy") {
                        SpriteView(scene: ParticleScene(fileName: "Cloudy.sks", anchor: CGPoint(x: 0.0, y: 1)), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Windy") {
                        SpriteView(scene: ParticleScene(fileName: "Wind.sks", anchor: CGPoint(x: 0.0, y: 1)), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Snow") {
                        SpriteView(scene: ParticleScene(fileName: "SnowFall.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                    }
                        
                    HStack {
                        VStack {
                            if current.temperature.value > 25 {
                                Image("temp-high").resizable().scaledToFit().frame(width: 75).offset(y: isBouncing ? 2 : -2)
                                    .animation(.interpolatingSpring(stiffness: 50, damping: 1).repeatForever(autoreverses: true))
                                    .onAppear {
                                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                            withAnimation {
                                                isBouncing.toggle()
                                            }
                                        }
                                    }
                            } else if current.temperature.value > 15 {
                                Image("temp-med").resizable().scaledToFit().frame(width: 75)
                            } else {
                                Image("temp-low").resizable().scaledToFit().frame(width: 75).offset(y: isBouncing ? 2 : -2)
                                    .animation(.interpolatingSpring(stiffness: 50, damping: 1).repeatForever(autoreverses: true))
                                    .onAppear {
                                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                            withAnimation {
                                                isBouncing.toggle()
                                            }
                                        }
                                    }
                            }
                            
                            let tUnit = current.temperature.unit.symbol
                            Text("\(current.temperature.value.formatted(.number.precision(.fractionLength(1))))\(tUnit)").font(Font.custom("PottaOne-Regular", size: 24)).foregroundColor(.black)
                        }.offset(y: 100)
                        
                        Spacer().frame(width: 650)
                    }
                    
                    Spacer()
                        
                    if isSunscreen {
                        PetSunscreenView(isSunscreen: self.$isSunscreen).frame(width: 350, height: 460).offset(y: 50)
                    } else if current.condition.description.contains("Rain") {
                        Image("chara-cold")
                            .offset(y: 50)
                            .animation(.bouncy)
                    } else if current.condition.description.contains("Clear") {
                        Image("chara-happy")
                            .offset(y: 50)
                            .offset(y: isBouncing ? 2 : -2)
                            .animation(.interpolatingSpring(stiffness: 50, damping: 1).repeatForever(autoreverses: true))
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                    withAnimation {
                                        isBouncing.toggle()
                                    }
                                }
                            }
                    } else {
                        Image("chara")
                            .offset(y: 50)
                            .animation(.bouncy)
                    }
                }
                
                VStack {
                    Spacer().frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    HStack {
                        Spacer()
                            .frame(width: 650)

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
