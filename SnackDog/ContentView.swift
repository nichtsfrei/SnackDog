import SwiftUI

extension Double {
    func printround(to: Int) -> String {
        return String(format: "%.\(to)f", self)
    }
}

extension Float {
    func printround(to: Int) -> String {
        return String(format: "%.\(to)f", self)
    }
}

extension Dog {
    func toEdog() -> EDog {
        let dog = self
        
        return EDog(
            id: self.id ?? UUID(),
            name: dog.name ?? "",
            birthDate: dog.birthdate ?? Date(),
            weight: Measurement(value: dog.weight, unit: dog.weight_unit.toMassUnit()),
            jod: Measurement(value: dog.jod, unit: dog.jod_unit.toMassUnit()),
            jodPer: Measurement(value: dog.jod_per, unit: dog.jod_per_unit.toMassUnit()),
            activityHours: dog.activity_hours,
            size: bcd_dog_size(UInt32(dog.size)),
            isNautered: dog.is_nautered,
            isOld: dog.is_old
        )
    }
}

struct SingleDogView: View {
    var dog: Dog
    @StateObject var shared: Shared
    
    var body: some View {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return GroupBox(label: HStack {
                Text(dog.name ?? "None")
                let uSymbol = dog.weight_unit.toMassUnit().symbol
                Text("(\(dog.weight.printround(to: 2)) \(uSymbol))" ).foregroundColor(.secondary)
            }) {
                HStack {
                    Image(systemName: "calendar.circle")
                    Text(formatter.string(from: dog.birthdate ?? Date()))
                    Spacer()

                    Button(action: {
                        let _ = shared.manipulator.remove(dog: dog)
                    }) {
                        Image(systemName: "trash")
                    }
                    Button(action: {
                        shared.selected = dog
                        shared.viewstate = .edit
                    }){
                        Image(systemName: "square.and.pencil")
                    }
                }
            }.onTapGesture {
                shared.selected = dog
                shared.viewstate = .foodplan
            }.onLongPressGesture{
                shared.selected = dog
                shared.viewstate = .edit
            }
        
    }
}

struct ContentView: View {
    
    @StateObject var refresh: Shared
    
    func newDog() -> EDog {
        return EDog(
            id: UUID(),
            name: "",
            birthDate: Date(),
            weight: Measurement<UnitMass>(value: 23.0, unit: .kilograms),
            jod: Measurement<UnitMass>(value: 631, unit: .milligrams),
            jodPer: Measurement(value: 1, unit: .kilograms),
            activityHours: 2,
            size: bcd_dog_medium,
            isNautered: false,
            isOld: false)
    }
    
    var body: some View {
        
        return NavigationView {
            
            VStack(alignment: .leading, spacing: 0.0) {
                ScrollView {
                    ForEach(refresh.fetcher.dogs) { dog in
                        SingleDogView(dog: dog, shared: refresh)
                        
                    }
                }
            }
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .leading
                )
                .toolbar{
                    HStack {
                        let dog = refresh.selected?.toEdog() ?? newDog()
                        NavigationLink(
                            destination: FoodPlan(dog: dog).navigationTitle("\(dog.name)"),
                            tag: .foodplan,
                            selection: $refresh.viewstate
                        ) {
                            EmptyView()
                        }
                        NavigationLink(
                            destination: EditView(refresh: refresh, dog: newDog()).navigationTitle("Add"),
                            tag: .add,
                            selection: $refresh.viewstate
                        ) {
                            EmptyView()
                        }
                        NavigationLink(
                            destination: EditView(refresh: refresh, dog: dog).navigationTitle("Edit"),
                            tag: .edit,
                            selection: $refresh.viewstate
                        ) {
                            EmptyView()
                        }
                        Button(action: {
                            refresh.viewstate = .add
                        }){
                            Image(systemName: "plus.app.fill")
                        }
                    }
                }
            //bottom_menu
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        let shared = Shared(
            fetcher: DogFetcher(managedObjectContext: vc),
            manipulator: DogManipulator(context: vc)
        )
        ContentView(refresh: shared)
            .previewDevice("iPhone 13 mini")
        
        
    }
}
