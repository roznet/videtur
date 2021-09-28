///  MIT License
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

import SwiftUI
import RZUtilsSwift
import RZUtils
@main
struct videturApp: App {
    @Environment(\.scenePhase) private var scenePhase

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
        
    init() {
        self.registerBackgroundTasks()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                RecordsListView(records: RecordKeeperObservable(recordKeeper: Model.shared.recordKeeper))
                    .tabItem {
                        Image( systemName: "location.viewfinder")
                        Text( "Locations" )
                    }
            
                LocationVisitsListView(visits: Model.shared.recordKeeper.countries)
                    .tabItem {
                        Image( systemName: "globe")
                        Text( "Countries")
                    }
                Text("Calendar")
                    .tabItem {
                        Image(systemName: "calendar.badge.clock")
                        Text( "Calendar" )
                    }
            }
        }
        .onChange(of: scenePhase){
            phase in
            RZSLog.info("Scene change \(phase)")
            self.sceneChange(phase: phase)
        }
    }
}
