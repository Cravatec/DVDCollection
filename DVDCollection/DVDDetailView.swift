//
//  DVDDetailView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI

struct DVDDetailView: View {
    let dvd: Dvd
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack{
                VStack {
                    if let data = dvd.coverImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250,
                                   alignment: .bottom)
                            .clipped()
                            .overlay(
                                GeometryReader { media in
                                    Image(dvd.media)
                                        .renderingMode(.original)
                                        .resizable(resizingMode: .stretch)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45,
                                               height: 40)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .position(x: media.size.width * 0.9, y: media.size.height * 0.95)
                                }
                            )
                    } else {
                        Image(systemName: "film")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250,
                                   alignment: .bottom)
                            .clipped()
                            .overlay(
                                GeometryReader { media in
                                    Image(dvd.media)
                                        .renderingMode(.original)
                                        .resizable(resizingMode: .stretch)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45,
                                               height: 40)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .position(x: media.size.width * 0.9, y: media.size.height * 0.95)
                                }
                            )
                    }
                }.background(Color.white)
                VStack{
                    VStack {
                        Text("\(dvd.titres.fr)")
                            .font(.title3)
                        Text("Original Title: \(dvd.titres.vo)").font(.footnote).padding(.horizontal).opacity(dvd.titres.vo.isEmpty ? 0 : 1)
                    }.allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .greatestFiniteMagnitude, maxHeight: .greatestFiniteMagnitude, alignment: .center)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                    HStack {
                        Text("Alternative Title: \(dvd.titres.alternatif)\(dvd.titres.alternatifVo)").opacity(dvd.titres.alternatif.isEmpty && dvd.titres.alternatifVo.isEmpty ? 0 : 1)
                    }.font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                    HStack {
                        Text("Year: \(dvd.annee)").opacity(dvd.annee.isEmpty ? 0 : 1)
                        Image(systemName: "barcode")
                        Text(": \(dvd.barcode)")
                    }.font(.footnote).frame(width: 500, height: 10, alignment: .center).foregroundColor(Color.white)
                    VStack {
                        Text("Editor: \(dvd.editeur)")
                        Text("Edition: \(dvd.edition)").opacity(dvd.edition.isEmpty ? 0 : 1)
                    }.font(.footnote).foregroundColor(Color.white)
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
                                    .font(.body)
                                Text(star.text)
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                        }
                    }.foregroundColor(Color.white)
                }.background(Color.black)
            }.frame(minWidth: 200,
                    maxWidth: .greatestFiniteMagnitude,
                    minHeight: 200,
                    maxHeight: .greatestFiniteMagnitude,
                    alignment:.center)
            .padding()
            .navigationBarTitle(dvd.titres.fr)
        }.background(Color.white)
    }
}

struct DVDDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DVDDetailView(dvd: Dvd(id: "12",
                               media: "DVD",
                               cover: "",
                               titres: Titres.init(fr: "Y a-t-il un pilote dans l'avion ? + Y a-t-il enfin un pilote dans l'avion ? 2",
                                                   vo: "Airplane! + Airplane II: The Sequel",
                                                   alternatif: "",
                                                   alternatifVo: ""),
                               annee: "2023",
                               edition: "Swift",
                               editeur: "Apple",
                               stars: Stars(star: [Star(type: .acteur, id: "22",
                                                        text: "Mr Machin"),
                                                   Star(type: .réalisateur,
                                                        id: "33", text: "Jean Duchemol"),
                                                   Star(type: .acteur, id: "44",
                                                        text: "Mme Michu")
                               ]), barcode: "3607483270608"))
    }
}
