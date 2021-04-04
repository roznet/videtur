//  MIT License
//
//  Created on 31/03/2021 for videtur (iOS)
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
import SwiftUI
import BackgroundTasks
import RZUtilsSwift
import RZUtils

extension videturApp {
    
    func backupGroupDb() {
        let groupdb = RZFileOrganizer.writeableFilePath("videtur.db", forGroup: "group.net.ro-z.videtur")
        let containerdb = RZFileOrganizer.writeableFilePath("videtur.db")
        
        if( FileManager.default.fileExists(atPath: groupdb)){
            if FileManager.default.fileExists(atPath: containerdb) {
                try? FileManager.default.removeItem(atPath: containerdb);
            }
            try? FileManager.default.copyItem(atPath: groupdb, toPath: containerdb)
        }
    }
    
    func sceneChange(phase: ScenePhase){
        if phase == .active {
            // Register location track
            self.scheduleLocationTrack()
            Model.shared.locationTracker.startTracking()
        }else if phase == .inactive {
            self.backupGroupDb()
        }
    }
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "net.ro-z.videtur.locationtrack", using: nil){
            task in
            guard let task = task as? BGAppRefreshTask else { return }
            RZSLog.info("Processing task \(task)")
            self.handleLocationTrackTask(task: task)
        }
    }
    
    func scheduleLocationTrack() {       
        let locationTrackTask = BGAppRefreshTaskRequest(identifier: "net.ro-z.videtur.locationtrack")
        locationTrackTask.earliestBeginDate = Date(timeIntervalSinceNow: 6.0*3600.0)
        do {
            try BGTaskScheduler.shared.submit(locationTrackTask)
            RZSLog.info("Submitted task \(locationTrackTask)")
        }catch{
            RZSLog.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    func handleLocationTrackTask(task : BGAppRefreshTask){
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            RZSLog.error("Task expired \(task)")
        }
        // schedule next one
        self.scheduleLocationTrack()
        Model.shared.locationTracker.startTracking {
            record in
            if let record = record {
                RZSLog.info("Background localization success \(record)")
            }else{
                RZSLog.warning("Background localization failed")
            }
            task.setTaskCompleted(success: true)
        }
    }

}
