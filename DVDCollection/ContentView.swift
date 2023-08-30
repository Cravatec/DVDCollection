//
//  ContentView.swift
//  DVDCollection
//
//  Created by Sam on 28/08/2023.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var isShowingScanner = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button {
                isShowingScanner = true
            } label: {
                Label("Scan", systemImage: "barcode.viewfinder")
                    .sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(codeTypes: [.ean13], showViewfinder: true, simulatedData: "3760137632648", shouldVibrateOnSuccess: true, completion: handleScan)
                    }
            }
        }
        .padding()
    }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
