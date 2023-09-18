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
    private let storageService: StorageService
    
    init(scannerService: ScannerService, storageService: StorageService) {
        self.scannerService = scannerService
        self.storageService = storageService
    }
    
    func fetchDVDs() {
        storageService.retrieve { result in
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
            case .failure(let error as NSError):
                DispatchQueue.main.async {
                    self?.isShowingMessage = true
                    
                    if error.domain == "BAD_EAN" {
                        self?.message = "Invalid barcode."
                        
                    } else if error.code == NSURLErrorNotConnectedToInternet {
                        self?.message = "No Internet connection found. Connect to Internet and try again."
                        
                    } else if error.code == NSURLErrorTimedOut {
                        self?.message = "The request to the server timed out. Please try again later."
                        
                    } else {
                        self?.message = "Sorry, can't download information of this media for the moment. Please try again later."
                        
                    }
                    
                }
            }
        }
    }
}
