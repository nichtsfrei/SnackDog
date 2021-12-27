import SwiftUI

struct EDog {
    var id: UUID
    var name: String
    var birthDate: Date
    var weight: Measurement<UnitMass>
    var activityHours: Int16
    var size: DogSize
    var isNautered: Bool
    var isOld: Bool
}

extension EDog: Equatable {
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
    
    @StateObject var refresh: Shared
    
    
    @State var dog: EDog
    @State var weightUnit: UnitMass
    
    init(refresh: Shared, dog: EDog) {
        self._refresh = StateObject(wrappedValue: refresh)
        self._dog = State(wrappedValue: dog)
        
        self._weightUnit = State(wrappedValue: dog.weight.unit)
        
        
    }
    
    let allowedWeight: [UnitMass] = [
        UnitMass.kilograms,
        UnitMass.grams,
        UnitMass.milligrams,
        UnitMass.micrograms
    ]
    
    private func save() {
        let _ = refresh.dogManipulator.put(dog: dog)
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
            // TODO change dog.size to string instead of int
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
            refresh.viewstate = .foodplan
        }
        .toolbar{
            HStack {
                Button(action: {
                    save()
                    refresh.viewstate = .foodplan
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
        let dog = PersistenceController.NewDog(vc: vc, i: 1)
        let shared = Shared(
            fetcher: Fetcher<Dog>(managedObjectContext: vc, basefetchRequest: Dog.fetchRequest()),
            manipulator: DogManipulator(context: vc)
        )
        return DogEditView(
            refresh: shared,
            dog: dog.toEdog()
        ).environment(\.managedObjectContext, vc)
    }
}
