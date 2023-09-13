//
//  DVDListViewModel.swift
//  DVDCollection
//
//  Created by Sam on 13/09/2023.
//

import Foundation

class DVDListViewModel: ObservableObject {
    @Published var isShowingMessage = false
    @Published var message: String = ""
    @Published var barcodeVM: String = ""
    @Published var dvds = [Dvd]()
    
    private let scannerService: ScannerService
    
    init(scannerService: ScannerService) {
        self.scannerService = scannerService
    }
    
    func fetchDVDs() {
        CoreDataStorage.shared.retrieve { result in
            switch result {
            case .success(let dvds):
                DispatchQueue.main.async {
                    self.dvds = dvds.sorted(by: { $0.titres.fr < $1.titres.fr })
                }
            case .failure(let error):
                print("Failed to fetch DVDs: \(error)")
            }
        }
    }
    
    func filteredDvds(searchText: String) -> [Dvd] {
        if searchText.isEmpty {
            return dvds // Return all DVDs if searchText is empty
        } else {
            // Filter DVDs based on the searchText
            return dvds.filter { $0.titres.fr.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func fetchDvdInfos(_ barcode: String) {
        self.barcodeVM = barcode
        
        // First it's checked if it's already on the DataBase.
        guard !scannerService.isBarcodeExist(barcode) else {
            message = "This disc is already in your collection."
            isShowingMessage = true
            return
        }
        
        // If not already in the DataBase, call the Api
        scannerService.fetchDvdInfo(barcode) { [weak self] result in
            switch result {
            case .success(let dvds):
                DispatchQueue.main.async {
                    self?.dvds = dvds
                    self?.isShowingMessage = false
                }
            case .failure:
                self?.message = "Sorry, can't download information of this media for the moment. Try again later."
                self?.isShowingMessage = true
            }
        }
    }
}
//
//final class DvdCollectionViewModel: ObservableObject {
//    @Published var isShowingMessage = false
//    @Published var message: String = ""
//    @Published var barcodeVM: String = ""
//    @Published var dvds = [Dvd]()
//    
//    private let scannerService: ScannerService
//    
//    init(scannerService: ScannerService) {
//        self.scannerService = scannerService
//    }
//    
//    func fetchDvdInfos(_ barcode: String) {
//        self.barcodeVM = barcode
//        
//        // First it's checked if it's already on the DataBase.
//        guard !scannerService.isBarcodeExist(barcode) else {
//            message = "This disc is already in your collection."
//            isShowingMessage = true
//            return
//        }
//        
//        // If not already in the DataBase, call the Api
//        scannerService.fetchDvdInfo(barcode) { [weak self] result in
//            switch result {
//            case .success(let dvds):
//                DispatchQueue.main.async {
//                    self?.dvds = dvds
//                    self?.isShowingMessage = false
//                }
//            case .failure:
//                self?.message = "Sorry, can't download information of this media for the moment. Try again later."
//                self?.isShowingMessage = true
//            }
//        }
//    }
//}
