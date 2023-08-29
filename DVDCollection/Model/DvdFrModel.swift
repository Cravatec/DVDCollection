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
struct Dvd: Decodable {
    let id: String
    let media: String
    let cover: String
    let titres: Titres
    let annee: String
    let edition: String
    let editeur: String
    let stars: Stars
}

// MARK: - Stars
struct Stars: Decodable {
    let star: [Star]
}

// MARK: - Star
struct Star: Decodable {
    let type: TypeEnum
    let id: String
    let text: String
}

enum TypeEnum: Decodable {
    case acteur
    case réalisateur
}

// MARK: - Titres
struct Titres: Decodable {
    let fr: String
    let vo: String
     let alternatif: String
     let alternatifVo: String
}

