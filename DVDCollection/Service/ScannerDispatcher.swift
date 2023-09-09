//
//  ScannerDispatcher.swift
//  DVDCollection
//
//  Created by Sam on 04/09/2023.
//

import Foundation
import SwiftUI
import CoreData

class ScannerDispatcher: ObservableObject {
    @Published var isShowingMessage = false
    @Published var isShowingDVDDetailView = false
    @Published var message: String = ""
    
    func barcodeCheck(barcode: String) {
        if CoreDataStorage.shared.isBarcodeExists(barcode: barcode) {
            // if barcode already exists in CoreData, show a message
            message = "This media is already in your collection."
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                isShowingMessage = true
            }
            
            return
        }
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
                // Show the DVD Detail View
                //                isShowingDVDDetailView = true
            case .failure(let error):
                print("Failed to save DVD data: \(error.localizedDescription)")
                message = "Failed to save DVD data: \(error.localizedDescription)"
                isShowingMessage = true
            }
        }
    }
}
