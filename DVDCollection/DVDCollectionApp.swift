//
//  DVDCollectionApp.swift
//  DVDCollection
//
//  Created by Sam on 28/08/2023.
//

import SwiftUI
import Firebase
import FirebaseCore


@main
struct DVDCollectionApp: App {
    
    init() {
      FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            DVDListView()
        }
    }
}
