//
//  FetchDvdFrApiTests.swift
//  DVDCollectionTests
//
//  Created by Sam on 16/09/2023.
//

import XCTest
import FirebaseCore
import Firebase
import Foundation
@testable import DVDCollection

class MockFetchDvdFrApi: FetchDvdFrApi {
    var data: Data?
    var error: Error?

    override func getDvdFrInfo(barcode: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            completion(.success(data))
        }
    }
}

class FetchDvdFrApiTests: XCTestCase {

    var api: MockFetchDvdFrApi!
    var xmlData: Data!

    override func setUp() {
        super.setUp()
        api = MockFetchDvdFrApi()

        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "FakeXML", withExtension: "xml") else {
            XCTFail("Missing file: FakeXML.xml")
            return
        }

        do {
            xmlData = try Data(contentsOf: url)
        } catch {
            XCTFail("Unable to read XML data from FakeXML.xml")
        }
    }

    func testGetDvdFrInfoReturnsData() {
        api.data = xmlData

        api.getDvdFrInfo(barcode: "3760137632648") { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, self.xmlData, "The data should match the expected data.")
            case .failure:
                XCTFail("The call should not result in an error.")
            }
        }
    }

    func testGetDvdFrInfoReturnsError() {
        let expectedError = NSError(domain: "Test", code: 123, userInfo: nil)
        api.error = expectedError

        api.getDvdFrInfo(barcode: "3760137632648") { result in
            switch result {
            case .success:
                XCTFail("The call should not result in success.")
            case .failure(let error as NSError):
                XCTAssertEqual(error, expectedError, "The error should match the expected error.")
            }
        }
    }


    func testGetDvdFrInfoWithNilDataAndError() {
        api.data = nil
        api.error = nil

        api.getDvdFrInfo(barcode: "1234567890") { result in
            switch result {
            case .success:
                XCTFail("The call should not result in success.")
            case .failure(let error):
                XCTAssertNotNil(error, "The call should result in an error.")
            }
        }
    }

}
