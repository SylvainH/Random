//
//  Random.swift
//
//  Created by Sylvain on 19/Mar/2015.
//  Updated 4/Jan/2016


import Foundation
import Darwin

/// - returns: a random UInt64 number in range of (0...UInt64.max)
public func random_UInt64() -> UInt64 {
    var rnd: UInt64 = 0
    arc4random_buf(&rnd, sizeofValue(rnd))
    return rnd
}

/// - returns: a random Int64 number (Int64.min...Int64.max)
public func random_Int64() -> Int64 {
    var rnd: Int64 = 0
    arc4random_buf(&rnd, sizeofValue(rnd))
    return rnd
}

/**
 - seealso: [source stackoverflow](http://stackoverflow.com/questions/10984974/why-do-people-say-there-is-modulo-bias-when-using-a-random-number-generator/10989061#10989061)
 - returns: a random uniform number from 0 up to but not including upper bound e.g. (0 ..<upper)
 */
public func random_uniform_UInt64(upper_bound: UInt64) -> UInt64 {
    // Generate 64-bit random value in a range that is
    // divisible by upper_bound: 
    
    guard (upper_bound > 0) else {
        return 0
    }
    
    let range = UInt64.max - UInt64.max % upper_bound
    var rnd: UInt64 = 0
    repeat {
        arc4random_buf(&rnd, sizeofValue(rnd))
    } while rnd >= range
    
    return rnd % upper_bound
}

/**
 - precondition: lower bound must be greater thatn Int64.min
 - returns: a random uniform number from lower bound up to but not including upper bound e.g. (lower..<upper)
*/
public func random_uniform_Int64(lower_bound: Int64, upper_bound: Int64) -> Int64 {
    precondition(lower_bound > Int64.min, "random_uniform_Int64() - lower index must be greater than Int64.min") //small restriction to make coding easier
    precondition(lower_bound < upper_bound, "random_uniform_Int64() - lower bound must be less than upper bound")
    
    var offset: UInt64 = 0
    if lower_bound < 0 { // allow negative ranges
        offset = UInt64(abs(lower_bound)) //Int64.min would not work here
    }
    
    let mini = UInt64(lower_bound + Int64(offset))
    let maxi = UInt64(upper_bound) + offset
    let rnd = random_uniform_UInt64(maxi-mini) + mini
    var result : Int64 = 0
    if rnd >= UInt64(Int64.max) {
        result = Int64(rnd - offset)
    } else {
        result = Int64(rnd) - Int64(offset)
    }
    return result
    
}

extension Array {
    /// Shuffles the array elements.
    mutating func shuffle() {
        guard (count > 1) else {
            return
        }
        let end = count - 1
        for i in 0..<end {
            let rnd = (i...end).randomInt
            swap(&self[i], &self[rnd])
        }
    }
    
    /// - returns: a copy of the array with the elements shuffled.
    func shuffled() -> [Element] {
        var newArray = [Element](self)
        newArray.shuffle()
        return newArray
    }
}

extension Range
{
    /** usage example: get an Int within the given Range:
        let r = (-1000 ... 1100).randomInt
    */
    var randomInt: Int {
        let start = startIndex as! Int
        let end = endIndex as! Int
            
        return Int(random_uniform_Int64(Int64(start), upper_bound: Int64(end)))
    }
}
