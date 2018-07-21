//
//  EArray.swift
//  MusicApp
//
//  Created by Patrick Hanna on 5/3/18.
//  Copyright © 2018 Patrick Hanna. All rights reserved.
//

import Foundation
import UIKit



///E stands for efficient 😁
class EArray<Element>{
    
    private var storage = [Int: Element]()
    
    init(array: Array<Element>) {
        self.add(contentsOf: array)
    }
    
    init() { }
    
    var elements: [Element]{
        if storage.isEmpty { return [] }
        var arrayToReturn: [Any] = Array(repeating: "y", count: storage.count)
        for i in 0...(storage.count - 1){
            arrayToReturn[i] = storage[i]!
        }
        return arrayToReturn as! [Element]
    }
    
    
    func removeAll(){
        storage.removeAll()
    }
    
    func add(_ element: Element){
        storage[storage.count] = element
    }
    
    func add(contentsOf array: [Element]){
        
        for element in array{
            add(element)
        }
        
    }
    
    func irateThrough<x>(array: [x], doSomething: (x) -> Element?){
        var z = storage.count
        for y in array{
            
            if let result = doSomething(y){
                self.storage[z] = result
                z += 1
            } else {continue}
            
        }
        
    }
    
    func addBatch (numberOfTimes: Int, doSomething: () -> Element){
        var z = storage.count
        let count = storage.count
        
        repeat{
            self.storage[z] = doSomething()
            z += 1
        } while  z < count + numberOfTimes
        
    }
    
    func addBatch(numberOfTimes: Int, doSomething: (Int) -> Element){
        
        var z = storage.count
        let count = storage.count
        
        repeat{
            self.storage[z] = doSomething(z - count)
            z += 1
        } while  z < count + numberOfTimes
    }
}





