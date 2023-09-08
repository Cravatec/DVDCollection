//
//  DetailView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI

struct DVDDetailView: View {
    let dvd: Dvd
    
    var body: some View {
        VStack {
            Image(systemName: "film")
                .resizable()
                .frame(width: 100, height: 150)
            Text("Title: \(dvd.titres.fr)")
                .font(.title)
            Text("Media: \(dvd.media)")
            Text("Original Title: \(dvd.titres.vo)")
            HStack {
                Text("Alternative Title: \(dvd.titres.alternatif)\(dvd.titres.alternatifVo)")
                Text("Year: \(dvd.annee)") 
            }.font(.subheadline)
            HStack {
                Text("Editor: \(dvd.editeur)")
                    .font(.footnote)
                Text("Edition: \(dvd.edition)")
                    .font(.footnote)
                Text("Barcode: \(dvd.barcode)")
            }
            Text("Cover: \(dvd.cover)")
                .font(.footnote)
            VStack(alignment: .leading) {
                Text("Stars:")
                    .font(.headline)
                let sortedStars = dvd.stars.star.sorted { star1, star2 in
                    if star1.type == .réalisateur {
                        return true
                    } else if star2.type == .réalisateur {
                        return false
                    } else {
                        return star1.text < star2.text
                    }
                }
                ForEach(sortedStars, id: \.identifier) { star in
                    HStack {
                        Text("\(star.type.rawValue):")
                            .font(.subheadline)
                        Text(star.text)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .navigationBarTitle(dvd.titres.fr)
    }
}

struct DVDDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DVDDetailView(dvd: Dvd(id: "12", media: "DVD", cover: "", titres: Titres.init(fr: "Les Azerty en été", vo: "The Qwerty", alternatif: "", alternatifVo: ""), annee: "2023", edition: "Swift", editeur: "Apple", stars: Stars(star: [Star(type: .acteur, id: "22", text: "Mr Machin")]), barcode: "12345654"))
    }
}
