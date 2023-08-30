//
//  ListView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI
import CodeScanner

struct DVDListView: View {
    @State private var isShowingScanner = false
    
    @StateObject private var viewModel = DVDListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.dvds, id: \.id) { dvd in
                NavigationLink(destination: DVDDetailView(dvd: dvd)) {
                    HStack {
                        Image(systemName: "film")
                        VStack(alignment: .leading) {
                            Text(dvd.titres.fr)
                                .font(.headline)
                            Text(dvd.annee)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationBarTitle("DVD Collection")
            .toolbar { Button {
                isShowingScanner = true
            } label: {
                Label("Scan", systemImage: "barcode.viewfinder")
                    .sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(codeTypes: [.ean13], showViewfinder: true, simulatedData: simulatedBarcode.randomElement()!, shouldVibrateOnSuccess: true, completion: handleScan)
                    }
            }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchDVDs()
        }
    }
    let simulatedBarcode = ["3760137632648", "5051889638940", "3700301045065", "5051889675693", "3333290005415", "5053083261993", "3701432014517"]
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let barcode = result.string
            print(barcode)
            FetchDvdFrApi().getDvdFrInfo(barcode: barcode)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

class DVDListViewModel: ObservableObject {
    @Published var dvds: [Dvd] = []
    
    func fetchDVDs() {
        CoreDataStorage.shared.retrieve { result in
            switch result {
            case .success(let dvds):
                DispatchQueue.main.async {
                    self.dvds = dvds
                }
            case .failure(let error):
                print("Failed to fetch DVDs: \(error)")
            }
        }
    }
}

struct DVDListView_Previews: PreviewProvider {
    static var previews: some View {
        DVDListView()
    }
}

