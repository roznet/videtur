//  MIT License
//
//  Created on 28/09/2021 for videtur
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

struct LocationVisitsSingleView: View {
    
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    @State var visit : LocationVisits
    
    var earliestString : String {
        Self.dateFormatter.string(from: self.visit.earliest)
    }

    var latestString : String {
        Self.dateFormatter.string(from: self.visit.latest)
    }

    var countString : String {
        return "\(visit.days.count) days"
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                HStack(){
                    Text(self.visit.location.isoCountryCode ?? "")
                    Text(self.visit.location.country?.flag ?? "")
                    Spacer()
                    HStack{
                        Text( self.countString )
                    }
                }
            }
            
            HStack {
                Text( "between \(self.earliestString) and \(self.latestString)" )
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#if DEBUG
struct LocationVisitsSingleView_Previews: PreviewProvider {
    static var previews: some View {
        let samples = Self.sampleCountryVisits
        
        LocationVisitsSingleView(visit: samples[0])
        LocationVisitsSingleView(visit: samples[1])
    }
    
    static var sampleCountryVisits : [LocationVisits] {
        guard let url = Bundle.main.url( forResource: "samplerecords", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return []
        }
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([LocationRecord].self, from: data) {
            let keeper = RecordKeeper(records: array)
            return keeper.countries
        }
        return []
        
    }

}
#endif
