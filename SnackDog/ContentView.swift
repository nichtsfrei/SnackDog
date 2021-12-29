import SwiftUI

extension String {
    static let supportedMassUnits: [String: UnitMass] =
    Locale.current.usesMetricSystem ? [
        "kg": .kilograms,
        "g": .grams,
        "mg": .milligrams,
        "µg": .micrograms,
        "ng": .nanograms,
    ] : [
        "lb": .pounds,
        "oz": .ounces,
        "st": .stones,
        "oz t": .ouncesTroy,
    ]
    func toUnitMass() -> UnitMass? {
        
        return String.supportedMassUnits[self]
        
    }
}

extension MeasurementData {
    func measurement() -> Measurement<UnitMass>? {
        if let unit = self.symbol?.toUnitMass() {
            return Measurement(value: self.value, unit: unit)
        }
        return nil
        
    }
}

extension Dog {
    func toEdog() -> EDog {
        let dog = self
        
        return EDog(
            id: self.id ?? UUID(),
            name: dog.name ?? "",
            birthDate: dog.birthdate ?? Date(),
            
            weight: dog.weight?.measurement() ?? Measurement(value: 0, unit: .kilograms) ,
            
            activityHours: dog.activity_hours,
            size: DogSize(rawValue: dog.typus ?? "small") ?? .small,
            isNautered: dog.is_nautered,
            isOld: dog.is_old
        )
    }
}

struct Sidebar: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    var body: some View {
        return List {
            NavigationLink(
                destination: DogsView()
            ) {
                Text("Dogs")
                
            }
            NavigationLink(
                destination: AlgaePowderView( )
            ) {
                Text("Algae Powder")
            }
        }.listStyle(SidebarListStyle())
    }
}

struct ContentView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    
   
    
    var body: some View {
        
        return NavigationView {
            Sidebar()
            DogsView()
            if dogs.isEmpty {
                DogEditView()
            } else {
                FoodPlanView(dog: dogs.first!.toEdog())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, vc)
            .previewDevice("iPhone 13 mini")
    }
}
