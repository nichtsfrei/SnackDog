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
    
    @StateObject var refresh: Shared
    
    
    
    
    var body: some View {
        let aF = Fetcher(managedObjectContext: refresh.dogManipulator.viewContext, basefetchRequest: JodData.fetchRequest())
        return List {
            NavigationLink(
                destination: DogsView(shared: refresh)
            ) {
                Text("Dogs (\(refresh.dogFetcher.data.count))")
                
            }
            NavigationLink(
                destination: AlgaePowderView.fromshared(shared: refresh)
            ) {
                Text("Algae Powder (\(aF.data.count))")
            }
        }.listStyle(SidebarListStyle())
    }
}

struct ContentView: View {
    
    @StateObject var refresh: Shared
    var jodFetcher: Fetcher<JodData>
    
    init(refresh: Shared) {
        self._refresh = StateObject(wrappedValue: refresh)
        jodFetcher = Fetcher(managedObjectContext: refresh.dogManipulator.viewContext, basefetchRequest: JodData.fetchRequest())
        
    }
    
    var body: some View {
        
        return NavigationView {
            Sidebar(refresh: refresh)
            DogsView(shared: refresh)
            if refresh.dogFetcher.data.isEmpty {
                DogEditView(refresh: refresh, dog: EDog.new())
            } else {
                FoodPlanView(dog: refresh.dogFetcher.data[0].toEdog(), jodData: jodFetcher.data)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        let shared = Shared(
            fetcher: Fetcher<Dog>(managedObjectContext: vc, basefetchRequest: Dog.fetchRequest()),
            manipulator: DogManipulator(context: vc)
        )
        
        ContentView(refresh: shared)
            .previewDevice("iPhone 13 mini")
    }
}
