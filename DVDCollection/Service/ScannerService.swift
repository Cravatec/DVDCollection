//
//  ScannerDispatcher.swift
//  DVDCollection
//
//  Created by Sam on 04/09/2023.
//

import Foundation
import SwiftUI
import CoreData

final class ScannerService: ObservableObject {
    
    // Fetch on DVDFr.com Api with the barcode scanned
    func fetchDvdInfo(_ barcode: String, completion: @escaping (Result<[Dvd], Error>) -> Void) {
        FetchDvdFrApi().getDvdFrInfo(barcode: barcode) { [self] result in
            switch result {
            case .success(let xmlData):
                let dvds = parseDvdFrAPIResponse(xml: xmlData)
                savingDvd(dvds: dvds, barcode: barcode)
                completion(.success(dvds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Check if a barcode is already on the DataBase
    func isBarcodeExist(_ barcode: String) -> Bool {
        return CoreDataStorage.shared.isBarcodeExists(barcode: barcode)
    }
    
    // Parsing the xml recived from the Api
    func parseDvdFrAPIResponse(xml: Data) -> [Dvd] {
        let dvds = xmlParserDvdFr(xml: xml)
        return dvds
    }
    
    // Saving the result of the parsing to the DataBase.
    func savingDvd(dvds: [Dvd], barcode: String) {
        let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
        
        CoreDataStorage.shared.save(dvds: dvds, barcode: barcode) { [self] result in
            switch result {
            case .success:
                print("Save in CoreData")
                // Refresh the DVDListView after the save
                NotificationCenter.default.post(name: refreshDVDListViewNotification, object: nil)
                
                // Fetch coverURL for saving in the DataBase
                if let firstDvd = dvds.first {
                    if let coverURL = URL(string: firstDvd.cover) {
                        downloadAndSaveImage(from: coverURL, into: firstDvd) { imageResult in
                            switch imageResult {
                            case .success:
                                print("Cover image saved successfully in CoreData.")
                            case .failure(let error):
                                // Handle the error if there was a problem downloading or saving the image.
                                print("Failed to save cover image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                // Refresh the DVDListView
                let seconds = 3.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    NotificationCenter.default.post(name: refreshDVDListViewNotification, object: nil)
                }
                
            case .failure(let error):
                print("Failed to save DVD data: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadAndSaveImage(from url: URL, into dvd: Dvd, completion: @escaping (Result<Void, Error>) -> Void) {
        // Fetch the CoverUrl to download
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ImageDataError", code: 0, userInfo: nil)))
                return
            }
            
            // Save the image data directly into DataBase
            CoreDataStorage.shared.update(dvd: dvd, coverImageData: data) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to save cover image: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
