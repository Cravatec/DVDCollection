//
//  StorageService.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import Foundation
import CoreData

protocol StorageService {
    func save(dvd: DvdFrModel, completion: (Result<(Void), Error>) -> Void)
    
    func retrieve(completion: (Result<[DvdFrModel], Error>) -> Void)
    
    func delete(_ dvd: DvdFrModel, completion: (Result<Void, Error>) -> Void)
}


final class CoreDataStorage: StorageService {
    
    
    static let shared = CoreDataStorage()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DVD_CoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    func save(dvd: DvdFrModel, completion: (Result<(Void), Error>) -> Void) {
        
    }
    
    func retrieve(completion: (Result<[DvdFrModel], Error>) -> Void) {
        
    }
    
    func delete(_ dvd: DvdFrModel, completion: (Result<Void, Error>) -> Void) {
        
    }
    
    
}
