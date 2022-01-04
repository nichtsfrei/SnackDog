import SwiftUI

fileprivate class DogEditViewModel: ObservableObject {
    var onCommit: (EDog) -> Void
    @Published var dog: EDog
    @Published var weightUnit: String
    
    init(_ dog: EDog, onCommit: @escaping (EDog) -> Void) {
        self.onCommit = onCommit
        self.dog = dog
        self.weightUnit = dog.weight.unit.symbol
    }
    
}

struct DogEditView: View {
    
    @StateObject fileprivate var vm: DogEditViewModel
    
    init(_ dog: EDog, onCommit: @escaping (EDog) -> Void) {
        self._vm = StateObject(wrappedValue: DogEditViewModel(dog, onCommit: onCommit))
    }
    
    var body: some View {
        
        let sizes: [DogSize] = DogSizeFactor.all.sorted{
            let now = Date()
            return $0.value.factor(now) < $1.value.factor(now)
        }.map{
            return $0.key
        }
        
        return VStack{
            HStack {
                Spacer()
                Text("Factor \(vm.dog.factor().formatted(.percent))").font(.footnote).foregroundColor(.secondary)
            }
            Form {
                
                Section {
                    HStack {
                        TextField("Name", text: $vm.dog.name)
                    }
                    DatePicker(selection: $vm.dog.birthDate, displayedComponents: .date, label: { Text("Birthdate") }).datePickerStyle(.compact)
                    HStack {
                        TextField("Weight", value: $vm.dog.weight.value, format: .number)
                        
                            .keyboardType(.decimalPad)
                        UnitMassPicker(symbol: $vm.weightUnit)
                        
                    }
                    
                    Picker("Breed size",
                           selection: $vm.dog.size) {
                        ForEach(sizes, id: \.rawValue) { index in
                            Text(index.rawValue).tag(index)
                        }
                    }.pickerStyle(.segmented)
                    HStack {
                        Toggle(isOn: $vm.dog.isNautered) {
                            Text("Nautered")
                        }
                        Toggle(isOn: $vm.dog.isOld) {
                            Text("Old")
                        }
                    }
                    
                    
                    Picker("Activity", selection: $vm.dog.activityHours) {
                        ForEach(0..<8) { i in
                            Text("\(i) hours").tag(Int16(i))
                        }
                    }
                }
            }
        }.onChange(of: vm.weightUnit){ njwu in
            let previous = vm.dog.weight
            vm.dog.weight = Measurement(value: previous.value, unit: njwu.toUnitMass() ?? .kilograms)
        }
        
        .detailsView {
            vm.onCommit(vm.dog)
        }
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
}
