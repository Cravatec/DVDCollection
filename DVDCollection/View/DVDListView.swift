//
//  DVDListView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI
import CodeScanner
import FirebaseAnalyticsSwift

struct DVDListView: View {
    @State private var isShowingScanner = false
    @State private var showAlert = false
    @State private var currentAlert: Alert?
    @State private var searchText = ""
    @State private var navigateToDetailView = false
    @State private var selectedDvd: Dvd?
    
    @StateObject private var viewModel = DVDListViewModel(scannerService: ScannerService(), storageService: CoreDataStorage.shared)
    
    
    let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5){
                HStack {
                    Text("DVD Collection")
                        .font(.body)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "barcode.viewfinder")
                    }
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.ean13],
                                    showViewfinder: true,
                                    simulatedData: simulatedBarcode.randomElement()!,
                                    shouldVibrateOnSuccess: true,
                                    completion: handleScan)
                }
                .onChange(of: isShowingScanner) { isPresented in
                    if !isPresented && viewModel.isShowingMessage {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            let newAlert = Alert(
                                title: Text("Error"),
                                message: Text(viewModel.message),
                                dismissButton: .default(Text("OK"))
                            )
                            print("✅\(viewModel.message)")
                            currentAlert = newAlert
                            showAlert = true
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    _ = currentAlert ?? Alert(title: Text("Error"), message: Text("Unknown error"))
                    
                    let filteredDvds = filteredBarcode(barcode: viewModel.barcodeVM, dvds: viewModel.dvds) // Pass dvds array
                    
                    return Alert(
                        title: Text("Attention"),
                        message: Text("\(viewModel.message)"),
                        primaryButton: .default(Text("View Disc")) {
                            // Handle navigation to DVDDetailView using NavigationLink
                            selectedDvd = filteredDvds.first
                            navigateToDetailView = true
                        },
                        secondaryButton: .default(Text("OK"))
                    )
                }
                
                VStack() {
                    SearchBar(text: $searchText, placeholder: "Search DVDs")
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], alignment: HorizontalAlignment.center, spacing: 10) {
                            
                            ForEach(searchText.isEmpty ? viewModel.dvds : viewModel.filteredDvds(searchText: searchText), id: \.id) { dvd in
                                NavigationLink(destination: DVDDetailView(dvd: dvd)) {
                                    DVDGridItem(dvd: dvd)
                                }
                            }
                        }
                        .padding()
                        
                        // NavigationLink to DVDDetailView when a barcode scanned is already in the DataBase and the user choose "View Media" button on the alert.
                        if let dvd = selectedDvd {
                            NavigationLink(destination: DVDDetailView(dvd: dvd), isActive: $navigateToDetailView) {
                                EmptyView()
                            }
                        }
                    }
                }
            }.background(Color(.systemGray6)).ignoresSafeArea()
            .analyticsScreen(name: "\(DVDListView.self)")
        }
        .padding()
        .onAppear {
            viewModel.fetchDVDs()
            setupNotificationObserver()
        }
        .background(Color(.systemGray6))
    }
    
    let simulatedBarcode = ["3760137632648", "5051889638940", "3700301045065", "5051889675693", "3333290005415", "5053083261993", "3701432014517", "3701432006000", "5051889700371", "5051889638957", "3333293820435", "7321950745685", "7321950809325", "5051889257400"]
    
    // take the scanned barcode and fetch
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let barcode = result.string
            viewModel.fetchDvdInfos(barcode)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(forName: refreshDVDListViewNotification, object: nil, queue: .main) { _ in
            viewModel.fetchDVDs()
        }
    }
    
    // Function to filter DVDs based on searchText
    func filteredBarcode(barcode: String, dvds: [Dvd]) -> [Dvd] {
        dvds.filter { $0.barcode.localizedCaseInsensitiveContains(barcode) }
    }
}


struct DVDListView_Previews: PreviewProvider {
    static var previews: some View {
        DVDListView()
    }
}
