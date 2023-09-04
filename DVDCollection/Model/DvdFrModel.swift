//
//  DvdFrModel.swift
//  DVDCollection
//
//  Created by Sam on 29/08/2023.
//

import Foundation

struct DvdFrModel {
    let dvds: Dvds
}

// MARK: - Dvds
struct Dvds: Decodable {
    let dvd: Dvd
}

// MARK: - DVD
struct Dvd: Identifiable, Decodable {
    let id: String
    let media: String
    let cover: String
    let titres: Titres
    let annee: String
    let edition: String
    let editeur: String
    let stars: Stars
    let barcode: String
}

// MARK: - Stars
struct Stars: Decodable {
    let star: [Star]
}

// MARK: - Star
struct Star: Decodable, Identifiable {
    let type: TypeEnum
    let id: String
    let text: String
    
    var identifier: String {
        return "\(id)-\(type)"
    }
}

enum TypeEnum: String, Decodable, RawRepresentable {
    case acteur = "Acteur"
    case réalisateur = "Réalisateur"
}
// MARK: - Titres
struct Titres: Decodable {
    let fr: String
    let vo: String
    let alternatif: String
    let alternatifVo: String
}
