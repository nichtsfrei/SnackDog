import SwiftUI

struct UnitMassPicker: View {
    let aha = String.supportedMassUnits.keys.sorted()
    @State var symbol: String
    
    init(symbol: String) {
        self._symbol = State(wrappedValue: symbol)
    }
    
    var body: some View {
        Picker("", selection: $symbol) {
            ForEach(aha, id: \.self) {
                Text($0)
            }
        }
    }
}


struct JodDataView: GroupBoxStyle {
    
    let data: JodData
    
    func makeBody(configuration: Configuration) -> some View {
        let jm = data.value?.measurement() ?? Measurement(value: 0, unit: .milligrams)
        let jp = data.per?.measurement() ?? Measurement(value: 0, unit: .kilograms)
        
        return GroupBox(label: Text(data.name ?? "")) {
            HStack {
                Text(jm.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
                Text("/").foregroundColor(.secondary)
                Text(jp.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
                Spacer()
                configuration.content
            }
        }
    }
}

struct AlgaePowderView: View {
    
    struct SingleView: View {
        let data: JodData
        
        @State var isAddViewActive: Bool = false
        let manipulator: Manipulator<JodData>
        var body: some View {
            return GroupBox {
                    Button(action: {
                        let _ = manipulator.remove(t: data)
                    }) {
                        Image(systemName: "trash")
                    }
                    NavigationLink(
                        destination: EditView(manipulator: manipulator, jod: data, view: $isAddViewActive),
                        isActive: $isAddViewActive) {
                        Image(systemName: "square.and.pencil")
                    }
                
            }.groupBoxStyle(JodDataView(data: data))
        }
        
    }
    
    
    struct EditView: View {
        let manipulator: Manipulator<JodData>
        var data: JodData?
        @State var value: Double
        @State var symbol: String
        @State var perValue: Double
        @State var perSymbol: String
        @State var name: String
        @Binding var view: Bool
        
        init(manipulator: Manipulator<JodData>, jod: JodData?, view: Binding<Bool>) {
            self.data = jod
            self.value = jod?.value?.value ?? 631
            self.symbol = jod?.value?.symbol ?? "mg"
            self.perValue = jod?.per?.value ?? 1
            self.perSymbol = jod?.per?.symbol ?? "kg"
            self.name = jod?.name ?? ""
            self.manipulator = manipulator
            self._view = view
        }
        
        func save() -> Bool {
            let _ = manipulator.withConext{
                let jd = JodData(context: $0)
                jd.id = data?.id ?? UUID()
                jd.name = name
                let jm = MeasurementData(context: $0)
                jm.id = UUID()
                jm.value = value
                jm.symbol = symbol
                let jp = MeasurementData(context: $0)
                jp.id = UUID()
                jp.value = perValue
                jp.symbol = perSymbol
                jd.value = jm
                jd.per = jp
                return jd
                
            }
            
            return manipulator.save()
        }
        
        var body: some View {
            return Form {
                GroupBox(label: Text("Name")) {
                    TextField("name", text: $name)
                }
                GroupBox(label: Text("Jod / Per")) {
                    HStack {
                        TextField("Jod", value: $value, format: .number)
                            .keyboardType(.decimalPad)
                        UnitMassPicker(symbol: symbol)
                        
                    }
                    HStack {
                        TextField("Per", value: $perValue, format: .number)
                            .keyboardType(.decimalPad)
                        UnitMassPicker(symbol: perSymbol)
                        
                    }
                }
            }.toolbar{
                HStack {
                    Button(action: {
                        let _ = save()
                        view = false
                    }) {
                        Image(systemName: "checkmark.square")
                    }
                }
                
            }.onSubmit {
                if save() {
                    view = false
                }
            }
        }
    }
    
    @StateObject var fetcher: Fetcher<JodData>
    let manipulator: Manipulator<JodData>
    
    @State var isAddViewActive: Bool
    
    init(jodFetcher: Fetcher<JodData>, manipulator: Manipulator<JodData>) {
        self._fetcher = StateObject(wrappedValue: jodFetcher)
        self.manipulator = manipulator
        self.isAddViewActive = jodFetcher.data.isEmpty
        
    }
    
    
    var body: some View {
        List{
            ForEach(fetcher.data) { jod in
                SingleView(data: jod, manipulator: manipulator)
            }
        }
        .toolbar{
            NavigationLink(
                destination: EditView(manipulator: manipulator, jod: nil, view: $isAddViewActive),
                isActive: $isAddViewActive) {
                Image(systemName: "plus.app")
            }
        }
        .navigationTitle("Algae Powder")
    }
    
    static func fromshared(shared: Shared) -> AlgaePowderView {
        let context = shared.dogManipulator.viewContext
        return AlgaePowderView(
            jodFetcher: Fetcher(managedObjectContext: context, basefetchRequest: JodData.fetchRequest()),
            manipulator: Manipulator(context: context)
        )
    }
    
    
}

struct JodView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        let jf = Fetcher<JodData>(managedObjectContext: vc, basefetchRequest: JodData.fetchRequest())
        NavigationView {
            AlgaePowderView(jodFetcher: jf, manipulator: Manipulator(context: vc))
        }
    }
}
