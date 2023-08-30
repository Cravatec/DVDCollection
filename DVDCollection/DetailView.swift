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
                .font(.footnote)}
            Text("Cover: \(dvd.cover)")
                .font(.footnote)
        }
        .padding()
        .navigationBarTitle(dvd.titres.fr)
    }
}

struct DVDDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DVDDetailView(dvd: Dvd(id: "12", media: "DVD", cover: "", titres: Titres.init(fr: "Les Azerty en été", vo: "The Qwerty", alternatif: "", alternatifVo: ""), annee: "2023", edition: "Swift", editeur: "Apple"))
    }
}
