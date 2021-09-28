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


struct LocationRecord : Codable,Identifiable {
    enum Status : Error {
        case ok
        case invalidDate
    }
    
    private enum CodingKeys: String, CodingKey {
        case recordId, timestamp, date, coordinate, location
    }
    
    let id = UUID()
    
    let recordId : Int?
    let timestamp : Date
    let date : Int // Format YYYYMMDD
    let coordinate : CLLocationCoordinate2D
    let location : Location
    
    var isoCountryCode : String? { self.location.isoCountryCode }
    var administrativeArea : String? { self.location.administrativeArea }
    var locality : String? { self.location.locality }
    var timeZone : TimeZone? { self.location.timeZone }
    
    var country : Country? {
        return self.isoCountryCode
    }
    
    var countryAsLocation : Location {
        return self.location.countryAsLocation
    }
    
    static let recordingDevice = RecordingDevice()
    
    private var day : Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        if let day = Int(formatter.string(from: self.timestamp)) {
            return day
        }else{
            return 0
        }
        //return Int( self.date.timeIntervalSince1970 / (3600.0 * 24.0) )
    }
    
    static var sqlLogCreationStatement = "CREATE TABLE recordLog (logID INTEGER PRIMARY KEY, timestamp REAL NONNULL, date INTEGER, latitude REAL, longitude REAL,device TEXT)"
    static var sqlCreationStatement = "CREATE TABLE recordLocation (recordId INTEGER PRIMARY KEY, timestamp REAL NONNULL, date INTEGER, latitude REAL,longitude REAL, isoCountryCode TEXT, administrativeArea TEXT, locality TEXT, timezone TEXT)"
        
    init(date : Date, coordinate : CLLocationCoordinate2D) {
        self.timestamp = date
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYYMMdd"
        if let day = Int(formatter.string(from: self.timestamp)) {
            self.date = day
        }else{
            self.date = 0
        }
        self.coordinate = coordinate
        self.location = Location()
        self.recordId = nil
    }
    
    init( record : LocationRecord, location : Location ){
        self.timestamp = record.timestamp
        self.date = record.date
        self.coordinate = record.coordinate
        self.recordId = record.recordId
        self.location = location
    }

    private init(record : LocationRecord, with id : Int) {
        self.timestamp = record.timestamp
        self.date = record.date
        self.coordinate = record.coordinate
        self.location = record.location
        self.recordId = id
    }
    
    private init( record : LocationRecord, placemark : CLPlacemark){
        self.timestamp = record.timestamp
        self.date = record.date
        self.coordinate = record.coordinate
        self.recordId = record.recordId
        self.location = Location(placemark: placemark)
    }
    
    init(res : FMResultSet) throws{
        guard let timestamp = res.date(forColumn: "timestamp") else { throw LocationRecord.Status.invalidDate }
        
        self.recordId = Int(res.int(forColumn: "recordId"))
        self.date = Int(res.int(forColumn: "date"))
        self.timestamp = timestamp
        self.coordinate = CLLocationCoordinate2D(latitude: res.double(forColumn: "latitude"), longitude: res.double(forColumn: "longitude"))
        self.location = Location(res: res)
    }
    
    func log(db : FMDatabase)  {
        let params : [String:Any] = [
            "date" : self.date,
            "timestamp" : self.timestamp,
            "latitude" : self.coordinate.latitude,
            "longitude" : self.coordinate.longitude,
            "device":Self.recordingDevice.uuid
        ]
        db.executeUpdate("INSERT INTO recordLog (timestamp,date,latitude,longitude,device) VALUES (:timestamp,:date,:latitude,:longitude,:device)", withParameterDictionary: params)
    }
    
    func save(db : FMDatabase) throws -> LocationRecord {
        var params : [String:Any] = [
            "date" : self.date,
            "timestamp" : self.timestamp,
            "latitude" : self.coordinate.latitude,
            "longitude" : self.coordinate.longitude,
        ]
        for (key,val) in self.location.sqlParamDictionary {
            params[key] = val
        }
        
        if let recordId = self.recordId {
            db.executeUpdate("UPDATE recordLocation SET timestamp = :timestamp, date = :date, latitude = :latitude, longitude = :longitude, isoCountryCode = :isoCountryCode, administrativeArea = :administrativeArea, locality = :locality, timezone = :timezone WHERE recordId = \(recordId)", withParameterDictionary: params)
            return self
        }else{
            db.executeUpdate("INSERT INTO recordLocation (timestamp,date,latitude,longitude,isoCountryCode,administrativeArea,locality,timezone) VALUES (:timestamp,:date,:latitude,:longitude,:isoCountryCode,:administrativeArea,:locality,:timezone)", withParameterDictionary: params)
            return LocationRecord(record: self, with: Int(db.lastInsertRowId) )
        }
    }
    
    func hasNewInformation(since: LocationRecord) -> Bool {
        if self.day != since.day {
            return true
        }
        return self.location != since.location
    }
    
    func geocoded(placemark : CLPlacemark) -> LocationRecord {
        return LocationRecord(record: self, placemark: placemark)
    }
}

extension LocationRecord : CustomStringConvertible {
    var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        var idstr = "noid"
        if let recordId = self.recordId {
            idstr = "\(recordId)"
        }
        
        let info = [
            idstr,
            "\(self.date)",
            formatter.string(from: self.timestamp),
            String(format: "(%.4f,%.4f)", self.coordinate.latitude, self.coordinate.longitude)
        ]
        return String(format:"RecordLocation(%@,%@)", info.joined(separator: ", "), self.location.description)
    }
}

extension LocationRecord : Equatable {
    static func == (lhs : LocationRecord, rhs : LocationRecord) -> Bool {
        return lhs.recordId == rhs.recordId && lhs.date == rhs.date && lhs.location == rhs.location
    }
}


