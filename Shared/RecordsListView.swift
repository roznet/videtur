//  MIT License
//
//  Created on 31/03/2021 for videtur
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
import RZUtils

struct RecordsListView: View {
    @ObservedObject var records : RecordKeeperObservable
    
    var body: some View {
        NavigationView {
            List(records.list) { record in
                NavigationLink(
                    destination: SingleRecordView(record: record) ){
                SingleRecordView(record: record)
                }
            }
            
        }
        
        
    }
}

#if DEBUG
struct RecordsList_Previews: PreviewProvider {
    static var previews: some View {

        RecordsListView(records: RecordKeeperObservable(records: Self.sampleRecords))
    }
    
    static var sampleRecords : [RecordLocation] {
        guard let url = Bundle.main.url( forResource: "samplerecords", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return []
        }
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([RecordLocation].self, from: data) {
            return array
        }
        return []
        
    }
}
#endif
