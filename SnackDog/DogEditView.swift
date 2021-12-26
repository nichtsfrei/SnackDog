import SwiftUI

extension Int16 {
    func toMassUnit() -> UnitMass {
        let bcdunit = bcd_weight_unit(UInt32(self))
        switch bcdunit {
        case bcd_kilo_gram:
            return UnitMass.kilograms
        case bcd_gram:
            return UnitMass.grams
        case bcd_milli_gram:
            return UnitMass.milligrams
        default:
            return UnitMass.micrograms
        }
        
    }
}

extension UnitMass {
    func toBCDUnit() -> bcd_weight_unit {
        switch self.symbol {
        case "kg":
            return bcd_kilo_gram
        case "g":
            return bcd_gram
        case "mg":
            return bcd_milli_gram
        default:
            return bcd_micro_gram
        }
    }
}


struct EDog {
    var id: UUID
    var name: String
    var birthDate: Date
    var weight: Measurement<UnitMass>
    var activityHours: Int16
    var size: bcd_dog_size
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
            size: bcd_dog_medium,
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
    
    let dogSizes: [bcd_dog_size] = [
        bcd_dog_small,
        bcd_dog_medium,
        bcd_dog_large
    ]
    
    
    private func save() {
        let _ = refresh.dogManipulator.put(dog: dog)
    }
    
    var body: some View {
        
        return Form {
            HStack {
                TextField("Name", text: $dog.name)
                DatePicker(selection: $dog.birthDate, displayedComponents: .date, label: { Text("") })
                
            }
            Picker(String(cString: bcd_dog_size_string(dog.size)),
                   selection: $dog.size.rawValue) {
                ForEach(0..<dogSizes.count) { index in
                    Text(String(cString: bcd_dog_size_string(dogSizes[index]))).tag(dogSizes[index].rawValue)
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
                        ForEach(0..<2, content: { index in
                            Text(allowedWeight[index].symbol).tag(allowedWeight[index])
                        })
                        
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
