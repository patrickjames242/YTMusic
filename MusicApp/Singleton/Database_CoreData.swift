//
//  Database.swift
//  MusicApp
//
//  Created by Patrick Hanna on 3/7/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import UIKit
import CoreData
import Foundation


//MARK: - CORE DATA
class Database{
    
    //MARK: - CORE DATA STACK
    
    static var context: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    
    private static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MusicApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    static func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("There was an error in the save context fuction")
                print(nserror)
                print(nserror.userInfo)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}





