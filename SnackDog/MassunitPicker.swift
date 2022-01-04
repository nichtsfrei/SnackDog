import SwiftUI

struct UnitMassPicker: View {
    let symbols: [String] = String.supportedMassUnits.sorted{ (arg0, arg1) in
        let (k1, v1) = arg0
        let (k2, v2) = arg1
        return v1.converter.value(fromBaseUnitValue: 1.0) < v2.converter.value(fromBaseUnitValue: 1.0)
        
    }.map {
        return $0.key
    }
    @Binding var symbol: String
    
    init(symbol: Binding<String>) {
        self._symbol = symbol
    }
    
    var body: some View {
        Picker("", selection: $symbol) {
            ForEach(symbols, id: \.self) {
                Text($0)
            }
        }.pickerStyle(.menu)
    }
}
