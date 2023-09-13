//
//  DVDGridItem.swift
//  DVDCollection
//
//  Created by Sam on 13/09/2023.
//

import Foundation
import SwiftUI

struct DVDGridItem: View {
    let dvd: Dvd
    
    var body: some View {
        VStack {
            VStack {
                if let data = dvd.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 190, alignment: .bottom)
                        .clipped()
                        .overlay(
                            GeometryReader { media in
                                Image(dvd.media)
                                    .resizable(resizingMode: .stretch)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 45, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(5)
                                    .position(x: media.size.width * 0.9, y: media.size.height * 0.93).shadow(radius: 1)
                            }
                        )
                } else {
                    Image(systemName: "film").imageScale(.large)
                }
            }
            VStack(alignment: .center) {
                Text(dvd.titres.fr)
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(alignment: .center)
                    .clipped().frame(maxWidth: 150)
                Text(dvd.annee)
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            }
        }.frame(minWidth: 170,
                maxWidth: .infinity,
                minHeight: 250,
                maxHeight: 300,
                alignment: .top)
        .clipped()
    }
}
