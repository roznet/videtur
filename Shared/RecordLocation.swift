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

extension CLLocationCoordinate2D: Codable {
     public func encode(to encoder: Encoder) throws {
         var container = encoder.unkeyedContainer()
         try container.encode(longitude)
         try container.encode(latitude)
     }
      
     public init(from decoder: Decoder) throws {
         var container = try decoder.unkeyedContainer()
         let longitude = try container.decode(CLLocationDegrees.self)
         let latitude = try container.decode(CLLocationDegrees.self)
         self.init(latitude: latitude, longitude: longitude)
     }
 }


struct RecordLocation : Codable {
    enum Status : Error {
        case ok
        case invalidDate
    }
    
    let recordId : Int?
    let date : Date
    let coordinate : CLLocationCoordinate2D
    let isoCountryCode : String?
    let locality : String?
    let timeZone : TimeZone?
    
    var day : Int {
        return Int( self.date.timeIntervalSince1970 / (3600.0 * 24.0) )
    }
    
    static var sqlCreationStatement = "CREATE TABLE recordLocation (recordId INTEGER PRIMARY KEY, date REAL NONNULL, latitude REAL,longitude REAL, isoCountryCode TEXT, locality TEXT, timezone TEXT)"
        
    init(date : Date, coordinate : CLLocationCoordinate2D) {
        self.date = date
        self.coordinate = coordinate
        self.isoCountryCode = nil
        self.locality = nil
        self.recordId = nil
        self.timeZone = nil
    }
    
    private init(record : RecordLocation, with id : Int) {
        self.date = record.date
        self.coordinate = record.coordinate
        self.isoCountryCode = record.isoCountryCode
        self.locality = record.locality
        self.timeZone = record.timeZone
        self.recordId = id
    }
    
    private init( record : RecordLocation, placemark : CLPlacemark){
        self.date = record.date
        self.coordinate = record.coordinate
        self.isoCountryCode = placemark.isoCountryCode
        self.locality = placemark.locality
        self.timeZone = placemark.timeZone
        self.recordId = record.recordId
    }
    
    init(res : FMResultSet) throws{
        guard let date = res.date(forColumn: "date") else { throw RecordLocation.Status.invalidDate }
        
        self.recordId = Int(res.int(forColumn: "recordId"))
        self.date = date
        self.coordinate = CLLocationCoordinate2D(latitude: res.double(forColumn: "latitude"), longitude: res.double(forColumn: "longitude"))
        self.isoCountryCode = res.string(forColumn: "country")
        self.locality = res.string(forColumn: "city")
        if let tzIdenfitier = res.string(forColumn: "timeZone"),
           let tz = TimeZone(identifier: tzIdenfitier) {
            self.timeZone = tz
        }else{
            self.timeZone = nil
        }
    }
    
    func save(db : FMDatabase) throws -> RecordLocation {
        let row : [Any] = [
            self.date,
            self.coordinate.latitude,
            self.coordinate.longitude,
            self.isoCountryCode ?? NSNull(),
            self.locality ?? NSNull(),
            self.timeZone != nil ? self.timeZone!.identifier : NSNull()
        ]
        
        if let recordId = self.recordId {

            try db.executeUpdate("UPDATE recordLocation SET date = ?, latitude = ?, longitude = ?, isoCountryCode = ?, locality = ?, timezone = ? WHERE recordId = \(recordId)", values: row)
            return self
        }else{
            try db.executeUpdate("INSERT INTO recordLocation (date,latitude,longitude,isoCountryCode,locality,timezone) VALUES (?,?,?,?,?,?)", values: row)
            return RecordLocation(record: self, with: Int(db.lastInsertRowId) )
        }
    }
    
    func geocoded(placemark : CLPlacemark) -> RecordLocation {
        return RecordLocation(record: self, placemark: placemark)
    }
    
    var flag : String {
        var rv = ""
        if let country = self.isoCountryCode?.uppercased() {
            for uS in country.unicodeScalars {
                if let nuS = UnicodeScalar(127397+uS.value) {
                    rv.unicodeScalars.append( nuS )
                }
            }
        }
        return rv
    }
}

extension RecordLocation : CustomStringConvertible {
    var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        var idstr = "noid"
        if let recordId = self.recordId {
            idstr = "\(recordId)"
        }
        
        var info = [
            idstr,
            formatter.string(from: self.date),
            "\(self.day)",
            String(format: "(%.4f,%.4f)", self.coordinate.latitude, self.coordinate.longitude)
        ]
        if let country = self.isoCountryCode {
            info.append(country)
            info.append(self.flag)
        }
        if let city = self.locality {
            info.append(city)
        }
        if let tz = self.timeZone?.identifier {
            info.append(tz)
        }
        return String(format:"RecordLocation(%@)", info.joined(separator: ", "))
    }
}
