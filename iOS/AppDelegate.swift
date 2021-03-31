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
import UIKit
import BackgroundTasks
import RZUtilsSwift

class AppDelegate : NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let launchOptions = launchOptions {
            RZSLog.info("Launched with \(launchOptions)")
        }else{
            RZSLog.info("Launched")
        }
        registerLocationTrack()
        return true
    }

    func registerLocationTrack() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "net.ro-z.videtur.locationtrack", using: nil){
            task in
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleLocationTrackTask(task: task)
        }
    }
    
    func scheduleLocationTrack() {
        BGTaskScheduler.shared.getPendingTaskRequests{
            tasks in
            RZSLog.info("found \(tasks)")
        }
        
        let locationTrackTask = BGAppRefreshTaskRequest(identifier: "net.ro-z.videtur.locationtrack")
        locationTrackTask.earliestBeginDate = Date(timeIntervalSinceNow: 3600.0)
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
            RZSLog.error("Task expirerd \(task)")
        }
        // schedule next one
        self.scheduleLocationTrack()
        Model.shared.locationTracker.startTracking {
            record in
            task.setTaskCompleted(success: true)
        }
    }
}
