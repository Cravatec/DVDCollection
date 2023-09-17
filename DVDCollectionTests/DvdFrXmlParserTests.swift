//
//  DvdFrXmlParserTests.swift
//  DVDCollectionTests
//
//  Created by Sam on 17/09/2023.
//

import XCTest
import FirebaseCore
import Foundation

@testable import DVDCollection

class DvdFrXmlParserTests: XCTestCase {
    
    var xmlParserTest: DvdFrXmlParser!
    
    override func setUp() {
        super.setUp()
        xmlParserTest = DvdFrXmlParser()
    }
    
    func testParserInitialization() {
        XCTAssertNotNil(xmlParserTest, "The parser should not be nil.")
    }
    
    
    func testParseEmptyXml() {
        let xmlBadString = ""
        let xmlData = xmlBadString.data(using: .utf8)!
        let xmlDvd = xmlParserDvdFr(xml: xmlData)
        XCTAssertTrue(xmlDvd.isEmpty, "Parsing empty data should return an empty array.")
    }
    
    func testParseInvalidData() {
        let xmlBadString = "<dvds><dvd><id>123</id>"
        let xmlData = xmlBadString.data(using: .utf8)!
        let xmlDvd = xmlParserDvdFr(xml: xmlData)
        XCTAssertTrue(xmlDvd.isEmpty, "Parsing invalid data should return an empty array.")
    }
    
    func testParseValidData() {
        let xmlString = """
            <dvds>
                <dvd>
                    <id>123</id>
                    <media>DVD</media>
                    <cover></cover>
                    <fr>Essai</fr>
                    <vo>Test</vo>
                    <annee>2023</annee>
                    <edition>Collector</edition>
                    <editeur>Pathé</editeur>
                    <star type="acteur" id="1">John Smith</star>
                </dvd>
            </dvds>
            """
        let data = xmlString.data(using: .utf8)!
        let xmlDvd = xmlParserDvdFr(xml: data)
        XCTAssertFalse(xmlDvd.isEmpty, "Parsing valid data should return a non-empty array.")
    }
    
    func testParseValidDataHasCorrectDVD() {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "FakeXML", withExtension: "xml") else {
            XCTFail("Missing file: FakeXML.xml")
            return
        }
        
        do {
            let xmlData = try Data(contentsOf: url)
            let xmlDvd = xmlParserDvdFr(xml: xmlData)
            XCTAssertEqual(xmlDvd.first?.id, "95879", "The first DVD should have the expected ID.")
        }  catch {
            XCTFail("Unable to read XML data from FakeXML.xml")
        }
    }
}
