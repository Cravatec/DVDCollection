//
//  DvdFrXmlParser.swift
//  DVDCollection
//
//  Created by Sam on 29/08/2023.
//

import Foundation

class DvdFrXmlParser: NSObject, XMLParserDelegate {
    
    var currentElement: String = ""
    var currentDVD: [String: String] = [:]
    var currentStar: [String: String] = [:]
    var stars: [Star] = []
    var dvds: [Dvd] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "dvd" {
            currentDVD = [:]
            stars = []
        } else if elementName == "star" {
            currentStar = [:]
            if let type = attributeDict["type"] {
                currentStar["type"] = type
            }
            if let id = attributeDict["id"] {
                currentStar["id"] = id
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
            case "id", "media", "cover", "fr", "vo", "annee", "edition", "editeur", "alternatif", "alternatif_vo":
                if currentDVD[currentElement] != nil {
                    currentDVD[currentElement]?.append(data)
                } else {
                    currentDVD[currentElement] = data
                }
            case "star":
                if currentStar["text"] != nil {
                    currentStar["text"]?.append(data)
                } else {
                    currentStar["text"] = data
                }
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "dvd" {
            let starsObject = Stars(star: stars)
            let dvd = Dvd(id: currentDVD["id"] ?? "",
                          media: currentDVD["media"] ?? "",
                          cover: currentDVD["cover"] ?? "",
                          titres: Titres(fr: currentDVD["fr"] ?? "",
                                         vo: currentDVD["vo"] ?? "",
                                         alternatif: currentDVD["alternatif"] ?? "",
                                         alternatifVo: currentDVD["alternatif_vo"] ?? ""),
                          annee: currentDVD["annee"] ?? "",
                          edition: currentDVD["edition"] ?? "",
                          editeur: currentDVD["editeur"] ?? "",
                          stars: starsObject, barcode: currentDVD["barcode"] ?? "")
            dvds.append(dvd)
            stars = [] // Reset the stars array for the next DVD
        } else if elementName == "star" {
            let starTypeString = currentStar["type"]
            let starType = starTypeString == "Acteur" ? TypeEnum.acteur : TypeEnum.réalisateur
            let star = Star(type: starType,
                            id: currentStar["id"] ?? "",
                            text: currentStar["text"] ?? "")
            stars.append(star)
        }
    }
}

func xmlParserDvdFr(xml:Data) -> [Dvd] {
    let parser = XMLParser(data: xml)
    let dvdParser = DvdFrXmlParser()
    parser.delegate = dvdParser
    parser.parse()
    
    print(dvdParser.dvds)
    print(dvdParser.stars)
    
    return dvdParser.dvds
}
