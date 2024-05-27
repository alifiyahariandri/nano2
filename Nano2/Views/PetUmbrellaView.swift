//
//  PetUmbrellaView.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 27/05/24.
//

import SwiftUI

struct PetUmbrellaView: View {
    @Binding var isUmbrella: Bool

    @State var imageName: String = "chara-cold"
    @State var isUmbrellaAppear: Bool = false

    @State var showAlert: Bool = false
    @State private var animateCircle: Bool = false

    var body: some View {
        ZStack {
            if imageName == "chara-cold" {
                Image(imageName)
                    .animation(.bouncy)
                    .offset(y: 50)
            }
            else {
                Image(imageName)
                    .animation(.bouncy)
                    .offset(y: 50)
                    .offset(x: -80, y: -100)
            }

            if !isUmbrellaAppear {
                ZStack {
                    Circle()
                        .foregroundColor(.white).opacity(0.5)
                        .frame(width: animateCircle ? 110 : 100, height: animateCircle ? 110 : 100)
                        .animation(
                            Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: animateCircle
                        )

                    Circle()
                        .foregroundColor(.white).opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                        .frame(width: animateCircle ? 60 : 50, height: animateCircle ? 110 : 100)
                        .animation(
                            Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: animateCircle
                        )
                }
                .offset(x: -100, y: -200)
                .onTapGesture(perform: {
                    self.imageName = "chara-umbrella"
                    self.isUmbrellaAppear.toggle()
                })
            }

        }.onAppear {
            animateCircle = true
        }
    }
}

struct PetUmbrellaView_Previews: PreviewProvider {
    @State static var isUmbrella = true

    static var previews: some View {
        PetUmbrellaView(isUmbrella: $isUmbrella)
    }
}
