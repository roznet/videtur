//  MIT License
//
//  Created on 27/03/2021 for videtur
//
//  Copyright (c) 2021 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import Foundation

struct LocationVisits {
    let location : Location
    var days : [Int] = []
    var earliest : Int
    var latest : Int
    
    init(record : RecordLocation) {
        self.location = record.location
        self.days = [ record.date ]
        self.earliest = record.date
        self.latest = record.date
    }
    
    mutating func add(other : RecordLocation) -> Bool {
        let date = other.date
        
        guard other.location == self.location && !days.contains(date) else { return false }
        
        days.append(date)
        days.sort { $0 < $1 }
        if date < self.earliest {
            self.earliest = date
        }
        if date > self.latest {
            self.latest = date
        }
        return true
    }
}

extension LocationVisits : CustomStringConvertible {
    var description: String {
        return String(format: "Visits(%@, days: %@)", self.location.description, self.days.sorted { $0 > $1 })
    }
}

extension LocationVisits : Equatable {
    static func == (lhs : LocationVisits, rhs : LocationVisits) -> Bool {
        return lhs.location == rhs.location && lhs.days == rhs.days
    }
}
