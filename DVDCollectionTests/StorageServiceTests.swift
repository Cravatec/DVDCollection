//
//  StorageServiceTests.swift
//  DVDCollectionTests
//
//  Created by Sam on 16/09/2023.
//

import XCTest
import CoreData
import FirebaseCore
@testable import DVDCollection

class MockStorageService: StorageService {
    var dvds: [Dvd] = []
    var error: Error?

    func save(dvds: [Dvd], barcode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            self.dvds.append(contentsOf: dvds)
            completion(.success(()))
        }
    }

    func retrieve(completion: (Result<[Dvd], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(dvds))
        }
    }

    func delete(_ dvd: Dvd, completion: (Result<Void, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
        } else {
            dvds.removeAll { $0.id == dvd.id }
            completion(.success(()))
        }
    }
}

final class StorageServiceTests: XCTestCase {
    
    func testSaveDvd() {
        let mockService = MockStorageService()
        let dvd = Dvd(id: "1", media: "DVD", cover: "cover", titres: Titres(fr: "fr", vo: "vo", alternatif: "alternatif", alternatifVo: "alternatifVo"), annee: "2022", edition: "edition", editeur: "editeur", stars: Stars(star: []), barcode: "1234567890")
        mockService.save(dvds: [dvd], barcode: dvd.barcode) { result in
            switch result {
            case .success:
                XCTAssertEqual(mockService.dvds.count, 1)
                XCTAssertEqual(mockService.dvds.first?.id, dvd.id)
            case .failure(let error):
                XCTFail("Save failed with error \(error)")
            }
        }
    }

    func testRetrieveDvds() {
        let mockService = MockStorageService()
        let dvd = Dvd(id: "1", media: "DVD", cover: "cover", titres: Titres(fr: "fr", vo: "vo", alternatif: "alternatif", alternatifVo: "alternatifVo"), annee: "2022", edition: "edition", editeur: "editeur", stars: Stars(star: []), barcode: "1234567890")
        mockService.dvds.append(dvd)
        mockService.retrieve { result in
            switch result {
            case .success(let dvds):
                XCTAssertEqual(dvds.count, 1)
                XCTAssertEqual(dvds.first?.id, dvd.id)
            case .failure(let error):
                XCTFail("Retrieve failed with error \(error)")
            }
        }
    }

    func testDeleteDvd() {
        let mockService = MockStorageService()
        let dvd = Dvd(id: "1", media: "DVD", cover: "cover", titres: Titres(fr: "fr", vo: "vo", alternatif: "alternatif", alternatifVo: "alternatifVo"), annee: "2022", edition: "edition", editeur: "editeur", stars: Stars(star: []), barcode: "1234567890")
        mockService.dvds.append(dvd)
        mockService.delete(dvd) { result in
            switch result {
            case .success:
                XCTAssertTrue(mockService.dvds.isEmpty)
            case .failure(let error):
                XCTFail("Delete failed with error \(error)")
            }
        }
    }

    func testRetrieveDvdsWithError() {
        let mockService = MockStorageService()
        mockService.error = NSError(domain:"", code:-1, userInfo:nil)
        mockService.retrieve { result in
            switch result {
            case .success:
                XCTFail("Retrieve should not succeed")
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, -1)
            }
        }
    }

    
}
