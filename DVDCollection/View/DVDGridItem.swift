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
                } else {
                    Image(systemName: "film").imageScale(.large)
                }
            }.background(Color.white)
                .frame(height: 190, alignment: .center).cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 2)
                ).shadow(radius: 1)
                .overlay(
                    GeometryReader { media in
                        Image(dvd.media)
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 40)
                            .background(Color.white)
                            .cornerRadius(5)
                            .position(x: media.size.width * 0.89, y: media.size.height * 0.92).shadow(radius: 1)
                    }
                )
            
            VStack(alignment: .center) {
                Text(dvd.titres.fr)
                    .font(.footnote).foregroundColor(Color("TextColor"))
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
        .background(Color(.systemGray6))
    }
}

struct DVDGridItem_Previews: PreviewProvider {
    static var previews: some View {
        DVDGridItem(dvd: Dvd.init(id: "12", media: "DVD", cover: "", titres: Titres(fr: "Y a-t-il un pilote dans l'avion ? + Y a-t-il enfin un pilote dans l'avion ? 2", vo: "", alternatif: "", alternatifVo: ""), annee: "2023", edition: "", editeur: "", stars: Stars(star: [Star.init(type: .réalisateur, id: "12", text: "Steven Spielberg")]), barcode: "12345545"))
    }
}
