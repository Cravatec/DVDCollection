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
                /*
                 On vérifie si le dictionnaire currentDVD avec le currentElement comme key a déjà une valeur, si oui c'est à dire une valeur(string) a été tronquée et une partie est stockée(la première partie bien évidemment),
                 alors on ajoute à cette valeur stockée la valeur suivante pour le même key (currentElement).
                 
                 Si non, on stocke la valeur(data) dans le dictionnaire currentDVD avec le key(currentElement) correspondant.
                 
                 A noter un dictionnaire ne contient que des clés ou keys uniques donc si une clé a deja une valeur et on assigne une valeur encore la première est cassée et remplacée par la dernière c'est pour cela pour le cas du key `fr` la valeur final stockée est 'égende'
                 */
                if currentDVD[currentElement] != nil {
                    currentDVD[currentElement]?.append(data)
                } else {
                    currentDVD[currentElement] = data
                }

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
