import SwiftUI

struct EDog: Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var weight: Measurement<UnitMass>
    var activityHours: Int16
    var size: DogSize
    var isNautered: Bool
    var isOld: Bool
    
    static func == (a: EDog, b: EDog) -> Bool {
        return a.id == b.id &&
        a.name == b.name &&
        a.birthDate == b.birthDate  &&
        a.weight == b.weight &&
        a.activityHours == b.activityHours &&
        a.size == b.size &&
        a.isNautered == b.isNautered &&
        a.isOld == b.isOld
    }
    
    static func new() -> EDog {
        return EDog(
            id: UUID(),
            name: "",
            birthDate: Date(),
            weight: Measurement<UnitMass>(value: 23.0, unit: .kilograms),
            activityHours: 2,
            size: .medium,
            isNautered: false,
            isOld: false)
    }
}

struct DogEditView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var dog: EDog
    @State var weightUnit: UnitMass
    @Binding var selected: Dog?
    @Binding var viewState: ViewState?
    
    
    init(selected: Binding<Dog?>, viewState: Binding<ViewState?>) {
        let workingCopy = selected.wrappedValue?.toEdog() ?? EDog.new()
        self._dog = State(wrappedValue: workingCopy)
        self._selected = selected
        self._viewState = viewState
        self._weightUnit = State(wrappedValue: workingCopy.weight.unit)
        
    }
    
    init() {
        self._dog = State(wrappedValue: EDog.new())
        self._weightUnit = State(wrappedValue: .kilograms)
        self._selected = Binding{ return nil } set: { _ in return }
        self._viewState = Binding{ return nil } set: { _ in return }
    }
    
    let allowedWeight: [UnitMass] = [
        UnitMass.kilograms,
        UnitMass.grams,
        UnitMass.milligrams,
        UnitMass.micrograms
    ]
    
    
    func setDog(_ toSave: Dog) {
        toSave.name = dog.name
        if toSave.weight == nil {
            toSave.weight = MeasurementData(context: viewContext)
            toSave.weight?.id = dog.id
        }
        toSave.weight?.value = dog.weight.value
        toSave.weight?.symbol = dog.weight.unit.symbol
        
        toSave.birthdate = dog.birthDate
        toSave.typus = dog.size.rawValue
        toSave.is_old = dog.isOld
        toSave.is_nautered = dog.isNautered
        toSave.activity_hours = dog.activityHours
        
        
    }
    
    private func save() {
        if let toSave = selected {
            setDog(toSave)
        } else {
            let toSave = Dog(context: viewContext)
            toSave.id = dog.id
            setDog(toSave)
            selected = toSave
        }
        do {
            try viewContext.save()
            
        } catch {
            print("ignoring error \(error)")
        }
        viewState = .foodplan
        
    }
    
    var body: some View {
        
        let sizes: [DogSize] = DogSizeFactor.all.keys.map{
            return $0
        }
        
        let symbols: [UnitMass] = String.supportedMassUnits.values.map{
            return $0
        }
        return Form {
            HStack {
                TextField("Name", text: $dog.name)
                DatePicker(selection: $dog.birthDate, displayedComponents: .date, label: { Text("") })
            }
            Picker(dog.size.rawValue,
                   selection: $dog.size) {
                ForEach(sizes, id: \.rawValue) { index in
                    Text(index.rawValue).tag(index)
                }
            }
            HStack {
                Toggle(isOn: $dog.isNautered) {
                    Text("Nautered")
                }
                Toggle(isOn: $dog.isOld) {
                    Text("Old")
                }
            }
            
            GroupBox(label: Text("Weight")) {
                HStack {
                    TextField("Weight", value: $dog.weight.value, format: .number)
                        .keyboardType(.decimalPad)
                    Picker(weightUnit.symbol, selection: $weightUnit) {
                        
                        ForEach(symbols, id: \.self) {
                            Text($0.symbol).tag($0)
                        }
                        
                    }
                }
            }
            GroupBox(label: Text("Hours of activity")) {
                TextField("Hours", value: $dog.activityHours, format: .number)
            }
            
            
        }.onChange(of: weightUnit){ njwu in
            let previous = dog.weight
            dog.weight = Measurement(value: previous.value, unit: njwu)
            
        }.onSubmit {
            save()
            
        }
        .toolbar{
            HStack {
                Button(action: {
                    save()
                }) {
                    Image(systemName: "checkmark.square")
                }
            }
        }
        
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        let dog: Dog? = PersistenceController.NewDog(vc: vc, i: 1)
        
        let bDog: Binding<Dog?> = Binding{
            return dog
        } set: { _ in
            //
        }
        let bState: Binding<ViewState?> = Binding{
            return nil
        } set: { _ in
            //
        }
        return DogEditView(selected: bDog, viewState: bState)
            .environment(\.managedObjectContext, vc)
    }
}
