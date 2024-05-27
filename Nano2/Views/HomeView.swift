//
//  HomeView.swift
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
    @State private var isBouncing = false
    @State private var isTempBouncing = false

    @State var currentLocation: CLLocation?
    
    @ObservedObject var locationManager = LocationManager()
    
    @State var isSunscreen: Bool = false
    @State var isSunscreenNeeded: Bool = false
    
    @State var isUmbrella: Bool = false
    
    @State var isRain: Bool = false
            
    var body: some View {
        NavigationStack {
            ZStack {
                if let current = locationManager.currentWeather {
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
                                        Image("high").onAppear(perform: {
                                            self.isSunscreenNeeded = true
                                        })
                                    } else if current.uvIndex.category.rawValue == "veryHigh" {
                                        Image("very high").onAppear(perform: {
                                            self.isSunscreenNeeded = true
                                        })
                                    } else {
                                        Image("extreme").onAppear(perform: {
                                            self.isSunscreenNeeded = true
                                        })
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
                            .onAppear(perform: {
                                self.isRain = false
                            })
                    } else if current.condition.description.contains("Haze") || current.condition.description.contains("Fog") {
                        SpriteView(scene: ParticleScene(fileName: "Haze.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency]).onAppear(perform: {
                            self.isRain = false
                        })
                    } else if current.condition.description.contains("Rain") {
                        SpriteView(scene: ParticleScene(fileName: "RainFall.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency])
                            .edgesIgnoringSafeArea(.all)
                            .onAppear(perform: {
                                self.isRain = true
                            })
                    } else if current.condition.description.contains("Cloudy") {
                        SpriteView(scene: ParticleScene(fileName: "Cloudy.sks", anchor: CGPoint(x: 0.0, y: 1)), options: [.allowsTransparency]).onAppear(perform: {
                            self.isRain = false
                        })
                    } else if current.condition.description.contains("Windy") {
                        SpriteView(scene: ParticleScene(fileName: "Wind.sks", anchor: CGPoint(x: 0.0, y: 1)), options: [.allowsTransparency]).onAppear(perform: {
                            self.isRain = false
                        })
                    } else if current.condition.description.contains("Snow") {
                        SpriteView(scene: ParticleScene(fileName: "SnowFall.sks", anchor: CGPoint(x: 0.5, y: 1)), options: [.allowsTransparency]).onAppear(perform: {
                            self.isRain = false
                        })
                    }
                        
                    HStack {
                        VStack {
                            if current.temperature.value > 35 {
                                Image("temp-high").resizable().scaledToFit().frame(width: 75).offset(y: isTempBouncing ? 2 : -2)
                                    .animation(.interpolatingSpring(stiffness: 50, damping: 1).repeatForever(autoreverses: true))
                                    .onAppear {
                                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                            withAnimation {
                                                isTempBouncing.toggle()
                                            }
                                        }
                                    }
                            } else if current.temperature.value > 15 {
                                Image("temp-med").resizable().scaledToFit().frame(width: 75)
                            } else {
                                Image("temp-low").resizable().scaledToFit().frame(width: 75).offset(y: isTempBouncing ? 2 : -2)
                                    .animation(.interpolatingSpring(stiffness: 50, damping: 1).repeatForever(autoreverses: true))
                                    .onAppear {
                                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                                            withAnimation {
                                                isTempBouncing.toggle()
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
                        PetSunscreenView(isSunscreen: self.$isSunscreen, isSunscreenNeeded: self.$isSunscreenNeeded).frame(width: 350, height: 460).offset(y: 50)
                    } else if isSunscreenNeeded {
                        Image("chara-hot")
                            .offset(y: 50)
                            .animation(.bouncy)
                        Image("bubble")
                            .offset(x: -200, y: -100)
                    } else if isUmbrella {
                        PetUmbrellaView(isUmbrella: self.$isUmbrella)
                    } else if isRain {
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
                                
                                if !isSunscreenNeeded {
                                    Image("no")
                                        .offset(x: 55, y: -55)
                                }
                            }
                        }
                        
                        Spacer().frame(width: 20)
                        
                        Button {
                            self.isUmbrella.toggle()
                        } label: {
                            ZStack {
                                Image("button")
                                Image("umbrella")
                                
                                if !isRain {
                                    Image("no")
                                        .offset(x: 55, y: -55)
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
        }
        .navigationBarBackButtonHidden()
    }
    
    func locationUpdated(location: CLLocation?, error: Error?) {}
}

#Preview {
    HomeView()
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
