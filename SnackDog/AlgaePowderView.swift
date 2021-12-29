import SwiftUI

struct UnitMassPicker: View {
    let symbols: [String] = String.supportedMassUnits.keys.map {
        return $0
    }
    @State var symbol: String
    
    init(symbol: String) {
        self._symbol = State(wrappedValue: symbol)
    }
    
    var body: some View {
        Picker("", selection: $symbol) {
            ForEach(symbols, id: \.self) {
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
        @Environment(\.managedObjectContext) private var viewContext
        let data: JodData
        
        @State var isAddViewActive: Bool = false
        
        var body: some View {
            return GroupBox {
                    Button(action: {
                        do {
                            viewContext.delete(data)
                            try viewContext.save()
                        } catch {
                            print("ignoring \(error)")
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                    NavigationLink(
                        destination: EditView(jod: data, view: $isAddViewActive).navigationBarTitle("Edit"),
                        isActive: $isAddViewActive
                    ) {
                        Image(systemName: "square.and.pencil")
                    }
                
            }
            .onLongPressGesture {
               isAddViewActive = true
            }
            .groupBoxStyle(JodDataView(data: data))
             
        }
    }
    
    
    struct EditView: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        var data: JodData?
        @State var value: Double
        @State var symbol: String
        @State var perValue: Double
        @State var perSymbol: String
        @State var name: String
        @Binding var view: Bool
        
        init(jod: JodData?, view: Binding<Bool>) {
            self.data = jod
            self.value = jod?.value?.value ?? 631
            self.symbol = jod?.value?.symbol ?? "mg"
            self.perValue = jod?.per?.value ?? 1
            self.perSymbol = jod?.per?.symbol ?? "kg"
            self.name = jod?.name ?? ""
            self._view = view
        }
        
        func jodData() -> JodData {
            if let jd = data {
                return jd
            }
            let jd = JodData(context: viewContext)
            jd.id = UUID()
            return jd
        }
        
        func measurement(_ md: MeasurementData?) -> MeasurementData {
            if let d = md {
                return d
            }
            let d = MeasurementData(context: viewContext)
            d.id = UUID()
            return d
        }
        
        
        func save() {
            let jd =  jodData()
                    
                jd.name = name
            let jm = measurement(jd.value)
                jm.value = value
                jm.symbol = symbol
            let jp = measurement(jd.per)
                jp.id = UUID()
                jp.value = perValue
                jp.symbol = perSymbol
                jd.value = jm
                jd.per = jp
            do {
                try viewContext.save()
                
            } catch {
                print ("ignoring \(error)")
            }
            view = false
            
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
                        save()
                    }) {
                        Image(systemName: "checkmark.square")
                    }
                }
                
            }.onSubmit {
                save()
            }
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JodData.name, ascending: true)],
        animation: .default)
    private var jodData: FetchedResults<JodData>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @State var isAddViewActive: Bool = false
    
    var body: some View {
        return List{
            ForEach(jodData) { jod in
                SingleView(data: jod)
            }
        }
        .toolbar{
            NavigationLink(
                destination:
                    EditView(jod: nil, view: $isAddViewActive).navigationTitle("Add"),
                isActive: $isAddViewActive) {
                Image(systemName: "plus.app")
            }
            
        }
        .navigationTitle("Algae Powder")
    }
    
}

struct JodView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        NavigationView {
            AlgaePowderView().environment(\.managedObjectContext, vc)
        }
    }
}
