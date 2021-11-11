//
//  CirclePlayerView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 22/07/2021.
//  Copyright © 2021 Andrew Donnelly. All rights reserved.
//

import SwiftUI

class Model: ObservableObject {
    @Published var trackName = ""
    @Published var artistName = ""
    @Published var artistImage = Image("Pop")
}

struct CirclePlayerView: View {
    @ObservedObject var sliderModel = Model()

    var body: some View {
        VStack {
            ZStack {
                sliderModel.artistImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 10, height: 10, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
            Text(sliderModel.trackName)
                .font(.custom("Rubik-Bold", size: 18.0))
            Text(sliderModel.artistName)
                .font(.custom("Rubik-Medium", size: 14.0))
        }
    }
}

struct CirclePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CirclePlayerView()
    }
}
