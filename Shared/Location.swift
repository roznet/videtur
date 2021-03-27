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
import CoreLocation
import FMDB

struct Location : Codable,Equatable,Hashable {
    let isoCountryCode : String?
    let administrativeArea : String?
    let locality : String?
    let timeZone : TimeZone?
    
    init(placemark : CLPlacemark? = nil) {
        self.isoCountryCode = placemark?.isoCountryCode
        self.locality = placemark?.locality
        self.timeZone = placemark?.timeZone
        self.administrativeArea = placemark?.administrativeArea
    }
    
    init(res:FMResultSet) {
        self.isoCountryCode = res.string(forColumn: "country")
        self.locality = res.string(forColumn: "city")
        self.administrativeArea = res.string(forColumn: "administrativeArea")
        if let tzIdenfitier = res.string(forColumn: "timeZone"),
           let tz = TimeZone(identifier: tzIdenfitier) {
            self.timeZone = tz
        }else{
            self.timeZone = nil
        }
    }
    
    var sqlParamDictionary : [String:Any] {
        return [
            "isoCountryCode" : self.isoCountryCode ?? NSNull(),
            "locality" : self.locality ?? NSNull(),
            "administrativeArea" : self.administrativeArea ?? NSNull(),
            "timezone" : self.timeZone?.identifier ?? NSNull()
        ]
    }
    
    static var emptyParamDictionary : [String:Any] {
        return [
            "isoCountryCode" : NSNull(),
            "locality" : NSNull(),
            "administrativeArea" : NSNull(),
            "timezone" : NSNull()
        ]

    }
    
    var country : Country? {
        return self.isoCountryCode
    }
}

extension Location : CustomStringConvertible {
    var description: String {
        var info : [String] = []
        if let country = self.isoCountryCode {
            info.append("\(country) \(country.flag)")
        }
        if let area = self.administrativeArea {
            info.append(area)
        }
        if let city = self.locality {
            info.append(city)
        }
        if let tz = self.timeZone?.identifier {
            info.append(tz)
        }
        if info.count > 0 {
            return String(format: "Location(%@)", info.joined(separator: ", "))
        }else{
            return "Location(Empty)"
        }
    }
}
