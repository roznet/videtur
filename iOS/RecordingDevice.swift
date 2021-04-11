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
import UIKit
import FMDB

struct RecordingDevice {
    let uuid : String
    let name : String
    let model : String
    
    enum Status : Error {
        case ok
        case internalError
    }
    
    var sqlParameters : [String:String] {
        return [ "uuid" : self.uuid, "name" : self.name, "model" : self.model ]
    }
    
    init(device : UIDevice = UIDevice.current) throws {
        guard let uuid = device.identifierForVendor else { throw RecordingDevice.Status.internalError }
        self.uuid = uuid.uuidString
        self.name = device.name
        self.model = device.localizedModel
        
    }
    
    func ensureDb(db : FMDatabase) {
        if !db.tableExists("recording_device") {
            db.executeUpdate("CREATE TABLE recording_device (device_id INTEGER PRIMARY KEY, uuid TEXT UNIQUE, name TEXT, model TEXT", withArgumentsIn: []);
        }
        
        let sqlParams = self.sqlParameters
        
        let res = db.executeQuery("SELECT * FROM recording_device WHERE uuid = :uuid", withParameterDictionary: ["uuid" : self.uuid ] )
        if res?.next() != nil,
           let saved_name = res?.string(forColumn: "name"),
           let saved_model = res?.string(forColumn: "model")
           {
            if saved_name != self.name || saved_model != self.model{
                db.executeUpdate("UPDATE recording_device SET name = :name, model = :model WHERE uuid = :uuid", withParameterDictionary: sqlParams)
            }
        }else{
            db.executeUpdate("INSERT INTO recording_device (uuid,name,model) VALUES (:uuid,:name,:model)",
                             withParameterDictionary: sqlParams)
        }
    }
}
