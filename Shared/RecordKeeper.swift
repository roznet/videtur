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
import FMDB
import RZUtils
import RZUtilsSwift

class RecordKeeper {
    
    static let recordChangedNotification = Notification.Name("RecordKeeper.recordChanged")
    
    enum Status : Error {
        case ok
        case invalidRecordWithoutId
    }
    
    let db : FMDatabase
    private var recordsDatabase : [Int:LocationRecord] = [:]
    
    var records : [LocationRecord] {
        let rv : [LocationRecord] = Array(self.recordsDatabase.values)
        return rv.sorted { $1.timestamp < $0.timestamp }
    }
    
    weak var model : Model? = nil
    
    init(db : FMDatabase) {
        self.db = db
    }
    
    init(records : [LocationRecord]){
        // in memory database
        self.db = FMDatabase(path: nil)
        var input : [Int:LocationRecord] = [:]
        for one in records {
            if let recordId = one.recordId {
                input[recordId] = one
            }
        }
        self.recordsDatabase = input
    }
        
    func load() {
        self.recordsDatabase = [:]
        var last : LocationRecord? = nil
        if let res = self.db.executeQuery("SELECT * FROM recordLocation", withParameterDictionary: nil) {
            while( res.next() ){
                if let one = try? LocationRecord(res: res),
                   let recordId = one.recordId{
                    if last == nil || one.hasNewInformation(since: last!) {
                        if one.location.isoCountryCode != nil {
                            self.recordsDatabase[recordId] = one
                            last = one
                        }
                    }
                }
            }
        }
        RZSLog.info("Loaded \(self.recordsDatabase.count) records" );
        
        NotificationCenter.default.post(name: Self.recordChangedNotification, object: self)
    }
    
    func log( record : LocationRecord ){
        record.log(db: self.db)
    }
    
    func add( record : LocationRecord ) -> LocationRecord? {
        let last = self.lastRecord
        if last == nil || record.hasNewInformation(since: last!) {
            guard let newRecord = try? record.save(db: self.db),
                  let recordId = newRecord.recordId else {
                      return nil
                  }
            recordsDatabase[recordId] = newRecord
            NotificationCenter.default.post(name: Self.recordChangedNotification, object: self)
            return newRecord
        }

        return nil
    }
    
    func update( record : LocationRecord) throws -> LocationRecord {
        guard let recordId = record.recordId else { throw RecordKeeper.Status.invalidRecordWithoutId }
        let newRecord = try record.save(db: self.db)
        self.recordsDatabase[recordId] = newRecord
        NotificationCenter.default.post(name: Self.recordChangedNotification, object: self)
        return newRecord
    }
    
    static func ensureDbStructure(db : FMDatabase){
        if !db.tableExists("recordLocation") {
            db.executeUpdate(LocationRecord.sqlCreationStatement, withArgumentsIn: [])
        }
        if !db.tableExists("recordLog") {
            db.executeUpdate(LocationRecord.sqlLogCreationStatement, withArgumentsIn: [])
        }
        LocationRecord.recordingDevice.ensureDb(db: db)
    }
        
    var lastRecord : LocationRecord? {
        var rv : LocationRecord? = nil
        for (_,v) in self.recordsDatabase {
            if rv == nil || rv!.date < v.date{
                rv = v
            }
        }
        return rv
    }

    var days : [DayVisits] {
        var found : [Int:DayVisits] = [:]
        for one in self.recordsDatabase.values{
            if var date = found[one.date] {
                if date.add(record: one) {
                    found[one.date] = date
                }
            }else{
                found[one.date] = DayVisits(record: one)
            }
        }
        return Array(found.values).sorted {
            $1.date < $0.date
        }
    }
    
    var locations : [LocationVisits] {
        var found : [Location:LocationVisits] = [:]
        for one in self.recordsDatabase.values{
            if var location = found[one.location] {
                if location.add(other: one) {
                    found[one.location] = location
                }
            }else{
                found[one.location] = LocationVisits(record: one)
            }
        }
        return Array(found.values).sorted {
            $1.latest < $0.latest
        }
    }
    
    var countries : [LocationVisits] {
        var found : [Location:LocationVisits] = [:]
        for one in self.recordsDatabase.values{
            let country = one.countryAsLocation
            let countryonly = LocationRecord(record: one, location: country)
            if var location = found[country] {
                if location.add(other: countryonly) {
                    found[country] = location
                }
            }else{
                found[country] = LocationVisits(record: countryonly)
            }
        }
        
        return Array(found.values).sorted {
            $1.latest < $0.latest
        }
    }

}
