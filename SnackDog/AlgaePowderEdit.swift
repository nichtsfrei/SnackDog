import SwiftUI

fileprivate class EditViewModel: ObservableObject {
    var id: UUID
    var onCommit: (AlgaePowder)->Void
    
    @Published var value: Double
    @Published var symbol: String
    @Published var perValue: Double
    @Published var perSymbol: String
    @Published var name: String
    
    init(jod: JodData?, onCommit: @escaping (AlgaePowder)->Void) {
        self.id = jod?.id ?? UUID()
        self.onCommit = onCommit
        
        self._value = Published(wrappedValue: jod?.value?.value ?? 631)
        self._symbol = Published(wrappedValue: jod?.value?.symbol ?? "mg")
        self._perValue = Published(wrappedValue: jod?.per?.value ?? 1)
        self._perSymbol = Published(wrappedValue: jod?.per?.symbol ?? "kg")
        self._name = Published(wrappedValue: jod?.name ?? "")
    }
    
    func save() {
        onCommit(
            AlgaePowder(
                id: id,
                name: name,
                jod: Measurement(value: value, unit: symbol.toUnitMass() ?? .kilograms),
                per: Measurement(value: perValue, unit: perSymbol.toUnitMass() ?? .kilograms))
        )
    }
}

struct EditForm: View {
    
    @StateObject fileprivate var vm: EditViewModel
    
    var body: some View {
        Form {
            GroupBox(label: Text("Name")) {
                TextField("name", text: $vm.name)
            }
            GroupBox(label: Text("Jod / Per")) {
                HStack {
                    TextField("Jod", value: $vm.value, format: .number)
                        .keyboardType(.decimalPad)
                    UnitMassPicker(symbol: $vm.symbol)
                    
                }
                HStack {
                    TextField("Per", value: $vm.perValue, format: .number)
                        .keyboardType(.decimalPad)
                    UnitMassPicker(symbol: $vm.perSymbol)
                    
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}

struct EditView: View {
    
    @StateObject fileprivate var vm: EditViewModel
    
    init(jod: JodData?, onCommit: @escaping (AlgaePowder)->Void) {
        self._vm = StateObject(wrappedValue: EditViewModel(jod: jod, onCommit: onCommit))
    }
    
    
    var body: some View {
        
        return EditForm(vm: vm)
            .detailsView{
                vm.save()
                
            }
        
    }
    
}

struct EditDialog: View {
    
    @StateObject fileprivate var vm: EditViewModel
    
    init(jod: JodData?, onCommit: @escaping (AlgaePowder)->Void) {
        self._vm = StateObject(wrappedValue: EditViewModel(jod: jod, onCommit: onCommit))
    }
    
    
    var body: some View {
        return EditForm(vm: vm)
            .detailsDialog{
                vm.save()
                
            }
    }
    
}
