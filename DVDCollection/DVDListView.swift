//
//  DVDListView.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import SwiftUI
import CodeScanner

struct DVDListView: View {
    @State private var isShowingScanner = false
    @State private var showAlert = false
    @State private var currentAlert: Alert?
    @State private var searchText = ""
    @State private var navigateToDetailView = false
    @State private var selectedDvd: Dvd?
    
    @StateObject private var viewModel = DVDListViewModel()
    
    @ObservedObject var dvdCollectionViewModel = DvdCollectionViewModel(scannerService: ScannerService())
    
    let scannerService = ScannerService()
    let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
    var barcode = ""
    
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
                    if !isPresented && dvdCollectionViewModel.isShowingMessage {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dvdCollectionViewModel.isShowingMessage = false
                            if !dvdCollectionViewModel.barcode.isEmpty {
                                showAlert = true
                            }
                            let newAlert = Alert(
                                title: Text("Error"),
                                message: Text(dvdCollectionViewModel.message),
                                dismissButton: .default(Text("OK"))
                            )
                            currentAlert = newAlert
                            showAlert = true
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    let alert = currentAlert ?? Alert(title: Text("Error"), message: Text("Unknown error"))
                    
                    //                    if scannerService.isBarcodeExist(barcode) {
                    let filteredDvds = filteredBarcode(barcode: barcode, dvds: viewModel.dvds) // Pass dvds array
                    
                    return Alert(
                        title: Text("Attention"),
                        message: Text("\(dvdCollectionViewModel.message)"),
                        primaryButton: .default(Text("View DVD")) {
                            // Handle navigation to DVDDetailView using NavigationLink
                            let dvd = filteredDvds.first
                            let selectedDvd = dvd
                            navigateToDetailView = true
                            //                                                                selectedDvd != nil
                            NavigationLink(destination: DVDDetailView(dvd: selectedDvd!), isActive: $navigateToDetailView) {
                                EmptyView()
                            }
                        },
                        secondaryButton: .default(Text("OK"))
                    )
                    //                    } else {
                    //                        return alert
                    //                    }
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
    
    let simulatedBarcode = ["3760137632648", "5051889638940", "3700301045065", "5051889675693", "3333290005415", "5053083261993", "3701432014517", "3701432006000", "5051889700371", "5051889638957", "3333293820435", "7321950745685", "7321950809325", "5051889257400"]
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        var barcode = barcode
        
        switch result {
        case .success(let result):
            barcode = result.string
            print(barcode)
            scannerService.fetchDvdInfo(barcode) { [self] fetchResult in
                switch fetchResult {
                case .success:
                    print("Fetch DVD info succeeded.")
                case .failure(let error):
                    print("Fetch DVD info failed: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.dvdCollectionViewModel.message = error.localizedDescription
                        if !isShowingScanner {
                            self.dvdCollectionViewModel.isShowingMessage = true
                        }
                    }
                }
            }
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

struct DVDGridItem: View {
    let dvd: Dvd
    
    var body: some View {
        VStack {
            VStack {
                if let data = dvd.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 190, alignment: .bottom)
                        .clipped()
                        .overlay(
                            GeometryReader { media in
                                Image(dvd.media).renderingMode(.original).resizable(resizingMode: .stretch).aspectRatio(contentMode: .fit).frame(width: 45, height: 40)
                                    .background(Color.white).cornerRadius(5)
                                    .position(x: media.size.width * 0.9, y: media.size.height * 0.95).shadow(radius: 1)
                            }
                        )
                } else {
                    Image(systemName: "film").imageScale(.large)
                }
            }
            VStack(alignment: .center) {
                Text(dvd.titres.fr)
                    .font(.footnote)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(alignment: .center)
                    .clipped().frame(maxWidth: 160)
                Text(dvd.annee)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }.frame(minWidth: 170, maxWidth: .infinity, minHeight: 250, maxHeight: 300, alignment: .top)
            .clipped()
        //            .shadow(color: .gray, radius: 8, x: 0, y: 4)
        
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding([.leading, .trailing], 4)
                .padding(.top, 8)
                .padding(.bottom, 4)
            Button(action: { text = "" }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(4)
            }
            .padding(.trailing, 8)
            .opacity(text.isEmpty ? 0 : 1)
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
    
    func filteredDvds(searchText: String) -> [Dvd] {
        if searchText.isEmpty {
            return dvds // Return all DVDs if searchText is empty
        } else {
            // Filter DVDs based on the searchText
            return dvds.filter { $0.titres.fr.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct DVDListView_Previews: PreviewProvider {
    static var previews: some View {
        DVDListView()
    }
}
