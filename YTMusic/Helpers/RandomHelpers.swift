//
//  RandomHelpers.swift
//  YTMusic
//
//  Created by Patrick Hanna on 10/20/19.
//  Copyright © 2019 Patrick Hanna. All rights reserved.
//

import Foundation


typealias CompletionResult<NewResult> = Result<NewResult, Error>

public struct GenericError: LocalizedError{
    public static var unknownError = GenericError(description: "An unknown error occured.")
    
    public var errorDescription: String?
    public init(description: String){
        self.errorDescription = description
        
    }
}
