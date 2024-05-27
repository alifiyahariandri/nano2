//
//  MapViewSunscreen.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 22/05/24.
//
import MapKit
import SwiftUI

struct MapView: View {
    @State var showAlert: Bool = false
    @ObservedObject var locationManager = LocationManager()
    
    @State var region: MKCoordinateRegion
    
    @State var isCustomLocationActive: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
//                    if region != nil {
                        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                            .onChange(of: region) { newRegion in
                                region = newRegion
                                
                                print(region)
                            }
//                    } else {
//                        Text("\(region)")
//                        Text("Locating...")
//                    }
                }.task {
                    self.locationManager.updateLocation(handler: locationUpdated)
                    
                }
                
                Image("pin").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50).offset(y: -25)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {} label: {
                            Image("no").resizable().aspectRatio(contentMode: .fit).frame(width: 85, height: 85)
                        }
                        Spacer().frame(width: 600)
                        
                        NavigationLink(
                            destination: CustomLocation(customLocation: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)),
                            label: {
                                Image("yes").resizable().aspectRatio(contentMode: .fit).frame(width: 85, height: 85)
                            }
                        )
                    }
                    
                    Spacer().frame(height: 35)
                }
            }
            .task {
                self.locationManager.updateLocation(handler: locationUpdated)
                
            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Location Updated"),
                    message: Text("\(region.center.latitude), \(region.center.longitude)"),
                    dismissButton: .default(Text("OK")) {}
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
        
    func locationUpdated(location: CLLocation?, error: Error?) {
        print(locationManager.location)

    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center.latitude == rhs.center.latitude &&
            lhs.center.longitude == rhs.center.longitude &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
