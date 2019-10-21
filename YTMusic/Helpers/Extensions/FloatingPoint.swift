//
//  FloatingPoint.swift
//  YTMusic
//
//  Created by Patrick Hanna on 10/20/19.
//  Copyright © 2019 Patrick Hanna. All rights reserved.
//

import Foundation
extension FloatingPoint{
    
    func roundedTo(numberOfDecimalPlaces: Int) -> Self{
        guard numberOfDecimalPlaces >= 0 else { fatalError("the numberOfDecimalPlaces entered is negative") }
        let operandIntVal = Int(truncating: (1 * pow(10, numberOfDecimalPlaces)) as NSNumber)
        let value = (self * Self(operandIntVal)).rounded() / Self(operandIntVal)
        return Self(signOf: value, magnitudeOf: value)
    }
    
}

