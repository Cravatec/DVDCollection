//
//  DVDDetailView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI
import FirebaseAnalyticsSwift

struct DVDDetailView: View {
    let dvd: Dvd
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack{
                VStack {
                    if let data = dvd.coverImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250,
                                   alignment: .bottom)
                            .clipped()
                    } else {
                        Image(dvd.media)
                    }
                }.background(Color.white)
                    .frame(height: 250, alignment: .center).cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white, lineWidth: 2)
                    ).shadow(radius: 5)
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
                
                VStack{
                    VStack {
                        Text("\(dvd.titres.fr)")
                            .font(.title3)
                            .fontWeight(.bold)
                            
                        Text("Original Title: \(dvd.titres.vo)")
                            .font(.footnote).foregroundColor(Color.gray)
                            .padding(.horizontal).opacity(dvd.titres.vo.isEmpty ? 0 : 1)
                    }
                    .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .greatestFiniteMagnitude,
                           maxHeight: .greatestFiniteMagnitude,
                           alignment: .center)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 20)
                    
                    HStack {
                        Text("Alternative Title: \(dvd.titres.alternatif)\(dvd.titres.alternatifVo)").opacity(dvd.titres.alternatif.isEmpty && dvd.titres.alternatifVo.isEmpty ? 0 : 1)
                    }
                    .font(.caption)
                    .multilineTextAlignment(.center).foregroundColor(Color.gray)
                    
                    HStack {
                        Text("Year: \(dvd.annee)").opacity(dvd.annee.isEmpty ? 0 : 1)
                        Image(systemName: "barcode")
                        Text(": \(dvd.barcode)")
                    }
                    .font(.footnote).foregroundColor(Color.gray)
                    .frame(width: 500,
                           height: 10,
                           alignment: .center)
                    
                    VStack {
                        Text("Editor: \(dvd.editeur)")
                        Text("Edition: \(dvd.edition)").opacity(dvd.edition.isEmpty ? 0 : 1)
                    }
                    .font(.body).foregroundColor(Color.gray)
                }
                VStack(alignment: .leading) {
                    Text("Stars:")
                        .font(.headline)
                    // Sort the stars by type
                    let sortedStars = dvd.stars.star.sorted
                    { star1, star2 in
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
                            Spacer()
                            Text(star.text)
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }.frame(minWidth: 200,
                    maxWidth: .greatestFiniteMagnitude,
                    minHeight: 200,
                    maxHeight: .greatestFiniteMagnitude,
                    alignment:.center)
            .padding()
            .analyticsScreen(name: "\(DVDDetailView.self)")
        }
        .background(Color(.systemGray6))
        .ignoresSafeArea()
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
                               stars: Stars(star: [Star(type: .acteur, id: "1",
                                                        text: "John Smith"),
                                                   Star(type: .réalisateur,
                                                        id: "33", text: "John Rambo"),
                                                   Star(type: .acteur, id: "4",
                                                        text: "Jane Zoe")
                               ]), barcode: "3607483270608"))
    }
}
