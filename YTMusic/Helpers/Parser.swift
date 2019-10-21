//
//  Parser.swift
//  YTMusic
//
//  Created by Patrick Hanna on 10/20/19.
//  Copyright © 2019 Patrick Hanna. All rights reserved.
//

import Foundation


extension Character{
    var isNumber: Bool{
        return CharacterSet(charactersIn: String(self)).isSubset(of: .decimalDigits)
    }
    var isLetter: Bool{
        return CharacterSet(charactersIn: String(self)).isSubset(of: .letters)
    }
}

struct Parser<Result>{
    let parse: (String) -> (Result, String)?
}

extension Parser{
    
    var many: Parser<[Result]>{
        return Parser<[Result]>(parse: { (input: String) -> ([Result], String)? in
            var result = [Result]()
            var remainder = input
            
            while let (loopResult, loopRemainder) = self.parse(String(remainder)){
                result.append(loopResult)
                remainder = loopRemainder
            }
            guard result.isEmpty == false else {return nil}
            return (result, remainder)
        })
    }
    
    
    func map<A>(transform: @escaping (Result) -> A) -> Parser<A>{
        Parser<A>{ input in
            self.parse(input).map{(transform($0.0), $0.1)}
        }
    }
    
    var firstOccurance: Parser<Result>{
        return Parser{ input in
            var remainingString = input

            while remainingString.isEmpty == false{
                if let result = self.parse(remainingString){
                    return result
                } else {
                    remainingString.removeFirst()
                }
            }
            return nil
        }
    }
    
    var ignoreSpaces: Parser<Result>{
        return Parser { input in
            var remainingString = input
            while remainingString.first == " "{
                remainingString.removeFirst()
            }
            return self.parse(remainingString)
        }
    }
    
    
}

struct Parsers{
    
    static let letter = getForPredicate{$0.isLetter}
    static let digit = getForPredicate{$0.isNumber}
    static let integer = digit.many.map{Int(String($0))!}
    static let word = letter.many.map{String($0)}
    
    static func getForPredicate(_ predicate: @escaping (Character) -> Bool) -> Parser<Character>{
        return Parser(parse: { input -> (Character, String)? in
            guard let first = input.first, predicate(first) else {return nil}
            return (first, String(input.dropFirst()))
        })
    }
    
}



