//
//  DataController.swift
//  Randomizer
//
//  Created by 虎澤謙 on 2024/07/26.
//

import CoreData

class DataController: ObservableObject{
    static let shared = DataController()
    let container = NSPersistentContainer(name: "historyDatas")
    init(){
        container.loadPersistentStores { description, error in
            if let error = error{
                print("Core Data failed to load: \(error.localizedDescription)")   
            }
        }
    }
    
    var viewContext: NSManagedObjectContext { // これ何
        return container.viewContext
    }
}
