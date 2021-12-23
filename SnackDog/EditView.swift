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
    func toBCDUnit() -> Int16 {
        switch self {
        case UnitMass.kilograms:
            return Int16(bcd_kilo_gram.rawValue)
        case UnitMass.grams:
            return Int16(bcd_gram.rawValue)
        case UnitMass.milligrams:
            return Int16(bcd_milli_gram.rawValue)
        default:
            return Int16(bcd_micro_gram.rawValue)
        }
    }
}


struct EDog {
    var id: UUID
    var name: String
    var birthDate: Date
    var weight: Measurement<UnitMass>
    var jod: Measurement<UnitMass>
    var jodPer: Measurement<UnitMass>
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
        a.jod == b.jod &&
        a.jodPer == b.jodPer &&
        a.activityHours == b.activityHours &&
        a.size == b.size &&
        a.isNautered == b.isNautered &&
        a.isOld == b.isOld
    }
}

struct EditView: View {
    
    @StateObject var refresh: Shared
    
    
    @State var dog: EDog
    @State var weightUnit: UnitMass
    @State var jodWeightUnit: UnitMass
    @State var jodPerWeightUnit: UnitMass
    
    init(refresh: Shared, dog: EDog) {
        self._refresh = StateObject(wrappedValue: refresh)
        self._dog = State(wrappedValue: dog)
        self._weightUnit = State(wrappedValue: dog.weight.unit)
        self._jodWeightUnit = State(wrappedValue: dog.jod.unit)
        self._jodPerWeightUnit = State(wrappedValue: dog.jodPer.unit)
        
        
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
        let _ = refresh.manipulator.put(dog: dog)
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
            GroupBox(label: Text("Jod / Per")) {
                HStack {
                    TextField("Jod", value: $dog.jod.value, format: .number)
                    Picker(jodWeightUnit.symbol, selection: $jodWeightUnit) {
                        ForEach(1..<allowedWeight.count, content: { index in
                            Text(allowedWeight[index].symbol).tag(allowedWeight[index])
                        })
                    }
                }
                HStack {
                    TextField("Per", value: $dog.jodPer.value, format: .number)
                    Picker(jodPerWeightUnit.symbol, selection: $jodPerWeightUnit) {
                        ForEach(0..<allowedWeight.count, content: { index in
                            Text(allowedWeight[index].symbol).tag(allowedWeight[index])
                        })
                    }
                }
            }

        }.onChange(of: dog) { newDog in
            //
        }
        .onChange(of: jodWeightUnit) { njwu in
            let previous = dog.jod
            dog.jod = Measurement(value: previous.value, unit: njwu)
        }.onChange(of: jodPerWeightUnit){ njwu in
            let previous = dog.jodPer
            dog.jodPer = Measurement(value: previous.value, unit: njwu)
        }.onChange(of: weightUnit){ njwu in
            let previous = dog.weight
            dog.weight = Measurement(value: previous.value, unit: njwu)
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
        let dog = Dog(context: vc)
        PersistenceController.ExtendDog(newItem: dog, i: 1)
        let shared = Shared(
            fetcher: DogFetcher(managedObjectContext: vc),
            manipulator: DogManipulator(context: vc)
        )
        return EditView(
            refresh: shared,
            dog: dog.toEdog()
        ).environment(\.managedObjectContext, vc)
    }
}
