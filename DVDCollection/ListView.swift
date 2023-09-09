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
    @State private var searchText = ""
    
    let refreshDVDListViewNotification = Notification.Name("RefreshDVDListViewNotification")
    
    var body: some View {
        NavigationView {
            VStack(){
                HStack {
                    Text("DVD Collection")
                        .font(.body)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "barcode.viewfinder")
                            .sheet(isPresented: $isShowingScanner) {
                                CodeScannerView(codeTypes: [.ean13], showViewfinder: true, simulatedData: simulatedBarcode.randomElement()!, shouldVibrateOnSuccess: true, completion: handleScan)
                            }
                    }
                }
                VStack() {
                    SearchBar(text: $searchText, placeholder: "Search DVDs")
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(searchText.isEmpty ? viewModel.dvds : viewModel.filteredDvds(searchText: searchText), id: \.id) { dvd in
                                NavigationLink(destination: DVDDetailView(dvd: dvd)) {
                                    DVDGridItem(dvd: dvd)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .alert(isPresented: $scannerDispatcher.isShowingMessage) {
                    Alert(title: Text("⚠️ Attention ⚠️"), message: Text(scannerDispatcher.message), dismissButton: .default(Text("OK")))}
                //  .navigationBarTitle("DVD Collection")
                .toolbar {
                    //                HStack {
                    //                    Text("DVD Collection")
                    //                        .font(.body)
                    //                        .fontWeight(.bold)
                    //                    Spacer()
                    //                    Button {
                    //                        isShowingScanner = true
                    //                    } label: {
                    //                        Label("Scan", systemImage: "barcode.viewfinder")
                    //                            .sheet(isPresented: $isShowingScanner) {
                    //                                CodeScannerView(codeTypes: [.ean13], showViewfinder: true, simulatedData: simulatedBarcode.randomElement()!, shouldVibrateOnSuccess: true, completion: handleScan)
                    //                            }
                    //                    }
                    //                }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchDVDs()
            setupNotificationObserver()
        }
    }
    
    let simulatedBarcode = ["3760137632648", "5051889638940", "3700301045065", "5051889675693", "3333290005415", "5053083261993", "3701432014517", "3701432006000", "5051889700371", "5051889638957"]
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let barcode = result.string
            print(barcode)
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
struct DVDGridItem: View {
    let dvd: Dvd
    
    var body: some View {
        HStack {
            VStack {
                if let data = dvd.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "film").imageScale(.large)
                }

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
//        let viewModel = DVDListViewModel()
//        viewModel.dvds = [
//Dvd(id: "123", media: "DVD", cover: "image", titres: Titres(fr: "Faux Titre DVD", vo: "Fake DVD Title", alternatif: "Titre Alternatif", alternatifVo: "Alternate Title"), annee: "2023", edition: "Édition THX", editeur: "Criterion", stars: Stars(star: [
//                Star(type: .acteur, id: "1", text: "Patrick Sebastion"),
//                Star(type: .acteur, id: "2", text: "Jean Reno"),
//                Star(type: .réalisateur, id: "3", text: "Stanley Kubrick")
//            ]), barcode: "5051889638940"),
//            Dvd(id: "231", media: "DVD", cover: "image", titres: Titres(fr: "Faux Titre DVD 2", vo: "Fake DVD Title 2", alternatif: "Titre Alternatif 2", alternatifVo: "Alternate Title 2"), annee: "1928", edition: "Édition VHS", editeur: "Criterion", stars: Stars(star: [
//                Star(type: .acteur, id: "1", text: "Patrick Sebastion"),
//                Star(type: .acteur, id: "2", text: "Jean Reno"),
//                Star(type: .réalisateur, id: "3", text: "Stanley Kubrick")
//            ]), barcode: "3701432014517")]
//        return DVDListView().environmentObject(viewModel)
        
//        DVDGridItem(dvd: Dvd(id: "123", media: "DVD", cover: "cover", titres: Titres(fr: "Hello", vo: "Hella", alternatif: "Toto", alternatifVo: "Titi"), annee: "2023", edition: "THX", editeur: "Criterion", stars: Stars(star: [
//                        Star(type: .acteur, id: "1", text: "Patrick Sebastion"),
//                        Star(type: .acteur, id: "2", text: "Jean Reno"),
//                        Star(type: .réalisateur, id: "3", text: "Stanley Kubrick")
//                    ]), barcode: "12344323"))
        
        DVDListView()
    }
}
