//
//  ScannerDispatcher.swift
//  DVDCollection
//
//  Created by Sam on 04/09/2023.
//

import Foundation
import SwiftUI
import CoreData

final class DvdCollectionViewModel: ObservableObject {
@Published var isShowingMessage = false
@Published var message: String = ""
@Published var barcodeVM: String = ""

private let scannerService: ScannerService

    init(scannerService: ScannerService) {
           self.scannerService = scannerService
       }

    func fetchDvdInfoMessenger(_ barcode: String) {
        self.barcodeVM = barcode
        scannerService.fetchDvdInfo(barcode) { [weak self] result in
            switch result {
            case .success(_):
                self?.isShowingMessage = false
            case .failure(let error):
                self?.message = error.localizedDescription
                self?.isShowingMessage = true
            }
        }
    }

}


final class ScannerService: ObservableObject {
    
    func fetchDvdInfo(_ barcode: String, completion: @escaping (Result<(), Error>) -> Void) {
        guard !isBarcodeExist(barcode) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "This disc is already in your collection."])))
            return
        }
        FetchDvdFrApi().getDvdFrInfo(barcode: barcode) { [self] result in
            switch result {
            case .success(let xmlData):
                let dvds = parseDvdFrAPIResponse(xml: xmlData)
                savingDvd(dvds: dvds, barcode: barcode)
            case .failure(_):
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Sorry, can't download information of this media for the moment. Try again later."])))
            }
        }
    }
    
     func isBarcodeExist(_ barcode: String) -> Bool {
        return CoreDataStorage.shared.isBarcodeExists(barcode: barcode)
    }
        
    func parseDvdFrAPIResponse(xml: Data) -> [Dvd] {
        let dvds = xmlParserDvdFr(xml: xml)
        return dvds
    }
    
    func savingDvd(dvds: [Dvd], barcode: String) {
        let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
        
        CoreDataStorage.shared.save(dvds: dvds, barcode: barcode) { [self] result in
            switch result {
            case .success:
                print("Save in CoreData")
                // Refresh the list view
                NotificationCenter.default.post(name: refreshDVDListViewNotification, object: nil)
                
                // fetch coverURL to save into data image in CoreData
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
                // Refresh the list view
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
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ImageDataError", code: 0, userInfo: nil)))
                return
            }
            
            // Save the image data directly into Core Data
            CoreDataStorage.shared.update(dvd: dvd, coverImageData: data) { result in
                switch result {
                case .success:
//                    print("Cover image saved successfully in CoreData.")
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to save cover image: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}