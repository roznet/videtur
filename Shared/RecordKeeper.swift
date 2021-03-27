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

class RecordKeeper {
    
    enum Status : Error {
        case ok
        case invalidRecordWithoutId
    }
    
    let db : FMDatabase
    var records : [Int:RecordLocation] = [:]
    
    weak var model : Model? = nil
    
    init(db : FMDatabase) {
        self.db = db
    }
    
    func add( record : RecordLocation ) -> RecordLocation? {
        guard let newRecord = try? record.save(db: self.db),
              let recordId = newRecord.recordId else {
            return nil
        }
        records[recordId] = newRecord
        return newRecord
    }
    
    func update( record : RecordLocation) throws -> RecordLocation {
        guard let recordId = record.recordId else { throw RecordKeeper.Status.invalidRecordWithoutId }
        let newRecord = try record.save(db: self.db)
        self.records[recordId] = newRecord
        return newRecord
    }
    
    static func ensureDbStructure(db : FMDatabase){
        if !db.tableExists("recordLocation") {
            db.executeUpdate(RecordLocation.sqlCreationStatement, withArgumentsIn: [])
        }
    }
        
    var days : [Day] {
        var found : [Int:Day] = [:]
        for one in self.records.values{
            if var day = found[one.day] {
                day.add(record: one)
            }else{
                found[one.day] = Day(record: one)
            }
        }
        return Array(found.values).sorted {
            $1.day < $0.day
        }
    }
}
