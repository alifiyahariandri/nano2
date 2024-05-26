//
//  Modal.swift
//  Nano2
//
//  Created by Alifiyah Ariandri on 21/05/24.
//

import SwiftUI

struct ModalView: View {
    @Binding var isActive: Bool

    var title: String
    var description: String
    var button: String
    var action: String

    @State private var offset: CGFloat = 1000

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 580, height: 390)
                .background(Color(red: 0.84, green: 0.82, blue: 0.55))
                .cornerRadius(50)
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 544, height: 354)
                .background(Color(red: 1, green: 0.99, blue: 0.86))
                .cornerRadius(31)
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 297.27966, height: 31.93373)
                .background(.white)
                .cornerRadius(50)
                .offset(x: -100, y: -150)
            VStack {
                Spacer().frame(height: 25)
                Text(title).font(Font.custom("PottaOne-Regular", size: 36))
                Text(description).font(Font.custom("Poppins-Regular", size: 28)).multilineTextAlignment(.center)
                    .foregroundColor(.black)
                Button {} label: {
                    Image(button)
                }
            }

            Button {
                close()
            } label: {
                Image("cancel")
            }.offset(x: 275, y: -175)
                
        }
        .offset(x: 0, y: offset)
        .onAppear {
            withAnimation(.bouncy()) {
                offset = 0
            }
        }
    }

    func close() {
        withAnimation(.bouncy()) {
            offset = 1000
            isActive = false
        }
    }
}

#Preview {
    ModalView(isActive: .constant(true), title: "Add Sunscreen", description: "Find a region with\nUV Index > 5", button: "go", action: "sunscreen")
}
