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
    @StateObject private var scannerDispatcher = ScannerDispatcher()
    
    let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
    
    var body: some View {
        NavigationView {
            List(viewModel.dvds, id: \.id) { dvd in
                NavigationLink(destination: DVDDetailView(dvd: dvd)) {
                    HStack {
                        VStack {
                            Image(systemName: "film").imageScale(.large)
                            Text(dvd.media)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        VStack(alignment: .leading) {
                            Text(dvd.titres.fr)
                                .font(.headline)
                            Text(dvd.titres.vo)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .padding(.trailing)
                            Text(dvd.annee)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(dvd.edition).font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .alert(isPresented: $scannerDispatcher.isShowingMessage) {
                Alert(title: Text("This Media is already in your collection"), message: Text(scannerDispatcher.message), dismissButton: .default(Text("OK")))}
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
            setupNotificationObserver()
        }
        }
        
        let simulatedBarcode = ["3760137632648", "5051889638940", "3700301045065", "5051889675693", "3333290005415", "5053083261993", "3701432014517", "3701432006000"]
        
        func handleScan(result: Result<ScanResult, ScanError>) {
            isShowingScanner = false
            
            switch result {
            case .success(let result):
                let barcode = result.string
                print(barcode)
              //  FetchDvdFrApi().getDvdFrInfo(barcode: barcode)
                scannerDispatcher.barcodeCheck(barcode: barcode)
            case .failure(let error):
                print("Scanning failed: \(error.localizedDescription)")
            }
        }
    
    func setupNotificationObserver() {
            NotificationCenter.default.addObserver(forName: refreshDVDListViewNotification, object: nil, queue: .main) { _ in
                viewModel.fetchDVDs()
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
                        self.dvds = dvds.sorted(by: { $0.titres.fr < $1.titres.fr })
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
