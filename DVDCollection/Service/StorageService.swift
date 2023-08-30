//
//  StorageService.swift
//  DVDCollection
//
//  Created by Sam on 30/08/2023.
//

import Foundation
import CoreData

protocol StorageService {

    func save(dvds: [Dvd], completion: @escaping (Result<Void, Error>) -> Void)
    
    func retrieve(completion: (Result<[Dvd], Error>) -> Void)
    
    func delete(_ dvd: Dvd, completion: (Result<Void, Error>) -> Void)
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
    
    func save(dvds: [Dvd], completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            do {
                for dvd in dvds {
                    let dvdEntity = DVD_CoreData(context: self.context)
                    dvdEntity.id = dvd.id
                    dvdEntity.annee = dvd.annee
                    dvdEntity.media = dvd.media
                    dvdEntity.cover = dvd.cover
                    dvdEntity.titleFr = dvd.titres.fr
                    dvdEntity.titleVo = dvd.titres.vo
                    dvdEntity.titleAlternatif = dvd.titres.alternatif
                    dvdEntity.titleAlternatifVo = dvd.titres.alternatifVo
                    dvdEntity.editeur = dvd.editeur
                    dvdEntity.edition = dvd.edition
                }
                
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func retrieve(completion: (Result<[Dvd], Error>) -> Void) {
        let context = CoreDataStorage.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DVD_CoreData")
        do {
            let results = try context.fetch(fetchRequest)
            var dvds: [Dvd] = []
            for result in results {
                let id = result.value(forKey: "id") as? String ?? ""
                let media = result.value(forKey: "media") as? String ?? ""
                let cover = result.value(forKey: "cover") as? String ?? ""
                let fr = result.value(forKey: "titleFr") as? String ?? ""
                let vo = result.value(forKey: "titleVo") as? String ?? ""
                let annee = result.value(forKey: "annee") as? String ?? ""
                let edition = result.value(forKey: "edition") as? String ?? ""
                let editeur = result.value(forKey: "editeur") as? String ?? ""
                let alternatif = result.value(forKey: "titleAlternatif") as? String ?? ""
                let alternatifVo = result.value(forKey: "titleAlternatifVo") as? String ?? ""
                let dvd = Dvd(id: id,
                              media: media,
                              cover: cover,
                              titres: Titres(fr: fr,
                                             vo: vo,
                                             alternatif: alternatif,
                                             alternatifVo: alternatifVo),
                              annee: annee,
                              edition: edition,
                              editeur: editeur)
                dvds.append(dvd)
            }
            completion(.success(dvds))
        } catch {
            completion(.failure(error))
        }
    }
    
    func delete(_ dvd: Dvd, completion: (Result<Void, Error>) -> Void) {
        let context = CoreDataStorage.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DVD_CoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", dvd.id)
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                context.delete(result)
            }
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
