//
//  Test.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 20/05/24.
//

import CoreLocation
import MapKit
import SpriteKit
import SwiftUI
import WeatherKit

struct HomeView: View {
    @State var attribution: WeatherAttribution?
    @State var isLoading = true
    @State var currentLocation: CLLocation?
    
    @State var stateText: String = "Loading.."
    
    @State var currentWeather: CurrentWeather?
    
    @ObservedObject var locationManager = LocationManager()
    
    @State var isSunscreen: Bool = false
    
    let formatter = DateFormatter()
    
    var weatherServiceHelper = WeatherData.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if locationManager.currentWeather?.isDaylight ?? false {
                    Image("wallpaper-day")
                } else {
                    Image("wallpaper-night")
                }
                                    
                if let current = currentWeather {
                    if current.condition.description.contains("Clear") {
                        SpriteView(scene: ParticleScene(fileName: "Clear.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                    } else if current.condition.description.contains("Haze") || current.condition.description.contains("Fog") {
                        SpriteView(scene: ParticleScene(fileName: "Haze.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
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
                                center: locationManager.location ?? CLLocationCoordinate2D(),
                                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                            )),
                            label: {
                                Image("map")
                            }
                        )
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer().frame(height: 200)
                    
                    Text("Your Location").font(Font.custom("Poppins-Regular", size: 18)).foregroundColor(.white)

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
                
                if isSunscreen {
                    PetSunscreenView(isSunscreen: self.$isSunscreen).frame(width: 350, height: 460).offset(y: 50)

                } else {
                    Image("chara")
                        .offset(y: 50)
                        .animation(.bouncy)
                }

                Text("\(currentWeather?.condition.description)")
            }
            .task {
                self.locationManager.updateLocation(handler: locationUpdated)
            }
            .onChange(of: locationManager.locationString) { _, _ in

                if let currentLocation = locationManager.location {
                    formatter.timeStyle = .medium
                    formatter.timeZone = locationManager.timeZone
                    DispatchQueue.main.async { [self] in
                        self.isLoading = false
                    }

                    Task.detached {
                        if let currentLocation = await locationManager.location {
                            let weatherData = await weatherServiceHelper.currentWeather(for: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                           
                            DispatchQueue.main.async { [self] in
                                self.currentWeather = weatherData
                                self.stateText = ""
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        self.stateText = "Cannot get your location."
                        self.isLoading = false
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    func locationUpdated(location: CLLocation?, error: Error?) {
        if let currentLocation = location, error == nil {
            DispatchQueue.main.async { [self] in
                self.isLoading = false
            }

            Task.detached {
                if let currentLocation = location {
                    let weatherData = await weatherServiceHelper.currentWeather(for: currentLocation)
//                    let attributionData = await weatherServiceHelper.weatherAttribution()

                    DispatchQueue.main.async { [self] in
                        self.currentWeather = weatherData
//                        self.attribution = attributionData
                        self.stateText = ""
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [self] in
                self.stateText = "Cannot get your location. \n \(error?.localizedDescription ?? "")"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    HomeView()
}

class Fall: SKScene {
    init(fileName: String) {
        super.init(size: UIScreen.main.bounds.size)
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.backgroundColor = .clear
        
        if let node = SKEmitterNode(fileNamed: fileName) {
            addChild(node)
        } else {
            print("Error: Could not load emitter node with file name: \(fileName)")
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        // Additional setup if needed
    }
}

class Slide: SKScene {
    init(fileName: String) {
        super.init(size: UIScreen.main.bounds.size)
        self.scaleMode = .resizeFill
        self.anchorPoint = CGPoint(x: 0.0, y: 1)
        self.backgroundColor = .clear
        
        if let node = SKEmitterNode(fileNamed: fileName) {
            addChild(node)
        } else {
            print("Error: Could not load emitter node with file name: \(fileName)")
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        // Additional setup if needed
    }
}

class ParticleScene: SKScene {
    init(fileName: String, anchor: CGPoint) {
        super.init(size: UIScreen.main.bounds.size)
        self.scaleMode = .resizeFill
        self.anchorPoint = anchor
        self.backgroundColor = .clear
        
        if let node = SKEmitterNode(fileNamed: fileName) {
            addChild(node)
        } else {
            print("Error: Could not load emitter node with file name: \(fileName)")
        }
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        // Additional setup if needed
    }
}
