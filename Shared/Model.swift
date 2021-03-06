//  MIT License
//
//  Created on 26/03/2021 for Videtur
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
import RZUtils

class Model {
    static var shared = Model()
    
    let locationTracker : LocationTracker
    let recordKeeper : RecordKeeper
    let photos : Photos
    
    init(dbpath : String = RZFileOrganizer.writeableFilePath("videtur.db", forGroup: "group.net.ro-z.videtur")) {
        let db = FMDatabase(path: dbpath)
        db.open()
        
        self.locationTracker = LocationTracker(db: db)
        
        RecordKeeper.ensureDbStructure(db: db)
        self.recordKeeper = RecordKeeper(db: db)
        
        self.photos = Photos()
        
        self.locationTracker.model = self
        self.recordKeeper.model = self
        
        self.recordKeeper.load()
    }
    
}
