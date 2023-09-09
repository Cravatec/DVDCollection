//
//  ScannerDispatcher.swift
//  DVDCollection
//
//  Created by Sam on 04/09/2023.
//

import Foundation
import SwiftUI
import CoreData


final class ScannerDispatcher: ObservableObject {
    @Published var isShowingMessage = false
    @Published var message: String = ""
    
    func fetchDvdInfo(_ barcode: String) {
        guard !isBarcodeExist(barcode) else {
            message = "This media is already in your collection."
            let seconds = 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                            isShowingMessage = true
                        }
            return
        }
        isShowingMessage = false
        FetchDvdFrApi().getDvdFrInfo(barcode: barcode) { [self] result in
            switch result {
            case .success(let xmlData):
                let dvds = parseDvdFrAPIResponse(xml: xmlData)
                savingDvd(dvds: dvds, barcode: barcode)
            case .failure(_):
                message = "Sorry, can't download information of this media for the moment. Try again later."
                isShowingMessage = true
            }
        }
    }
    
    private func isBarcodeExist(_ barcode: String) -> Bool {
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
                
                // Show the DVD Detail View
                //                isShowingDVDDetailView = true
                
            case .failure(let error):
                print("Failed to save DVD data: \(error.localizedDescription)")
                message = "Failed to save DVD data: \(error.localizedDescription)"
                isShowingMessage = true
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
                    print("Cover image saved successfully in CoreData.")
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to save cover image: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
        
    }
}
