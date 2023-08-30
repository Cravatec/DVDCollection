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
    var dvds: [DvdFrModel] = []
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "dvd" {
            currentDVD = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
            case "id", "media", "cover", "fr", "vo", "annee", "edition", "editeur", "alternatif", "alternatif_vo":
                currentDVD[currentElement] = data
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "dvd" {
            let dvd = DvdFrModel(dvds: Dvds(dvd: Dvd(id: currentDVD["id"] ?? "",
                                                     media: currentDVD["media"] ?? "",
                                                     cover: currentDVD["cover"] ?? "",
                                                     titres: Titres(fr: currentDVD["fr"] ?? "",
                                                                    vo: currentDVD["vo"] ?? "",
                                                                    alternatif: currentDVD["alternatif"] ?? "",
                                                                    alternatifVo: currentDVD["alternatif_vo"] ?? ""),
                                                     annee: currentDVD["annee"] ?? "",
                                                     edition: currentDVD["edition"] ?? "",
                                                     editeur: currentDVD["editeur"] ?? "")))
            dvds.append(dvd)
        }
    }
}

func xmlParserDvdFr(xml:Data){
    let parser = XMLParser(data: xml)
    let dvdParser = DvdFrXmlParser()
    parser.delegate = dvdParser
    parser.parse()
    
    print(dvdParser.dvds)
    
}
