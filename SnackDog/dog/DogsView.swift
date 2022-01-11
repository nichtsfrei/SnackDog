import SwiftUI




fileprivate struct SingleDogView: View {
    
    @State var dog: Dog
    @Binding var updated: Bool
    @EnvironmentObject var jodFetcher: Fetcher<JodData>
    @EnvironmentObject var foodPlanFetcher: Fetcher<FoodPlanData>
    
    var body: some View {
        let formatter = DateFormatter()
        let name = dog.name ?? "Unknown"
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return NavigationLink(
            destination: FoodPlanView(dog: dog.toEdog(), fetcher: jodFetcher, defaultFetcher: foodPlanFetcher)
        ) {
            GroupBox(label: HStack {
                Text(name)
                if let weight = dog.weight?.measurement() {
                    Text(weight.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
                }
            }) {
                HStack {
                    Image(systemName: "calendar.circle")
                    Text(formatter.string(from: dog.birthdate ?? Date()))
                    Spacer()
                }
            }
        }
    }
}

fileprivate extension Fetcher {
    
 
    
    func getOrCreate(_ d: Dog?) -> Dog {
        if let dog = d {
            return dog
        }
        return self.withConext{
            let dog = Dog(context: $0)
            return dog
        }
    }
    
    func save(_ changed: EDog, _ basedOn: Dog?) {
        
        let dog: Dog = getOrCreate(basedOn)
        dog.id = changed.id
        dog.name = changed.name
        dog.weight = measurementData(md: dog.weight)
        dog.weight?.symbol = changed.weight.unit.symbol
        dog.weight?.value = changed.weight.value
        dog.birthdate = changed.birthDate
        dog.typus = changed.size.rawValue
        dog.is_old = changed.isOld
        dog.is_nautered = changed.isNautered
        dog.activity_hours = changed.activityHours
        
        self.save()
        self.selected = nil
        self.updated.toggle()
        
    }
}

struct ProgramStartView: View {
    
    @EnvironmentObject var fetcher: Fetcher<Dog>
    @EnvironmentObject var jodFetcher: Fetcher<JodData>
    @EnvironmentObject var foodPlanFetcher: Fetcher<FoodPlanData>
    
    
    var body: some View {
        if fetcher.data.isEmpty {
            DogEditView(EDog.new()) { update in
                let _ = fetcher.save(update, nil)
            }
        } else {
            FoodPlanView(dog: fetcher.data.first!.toEdog(), fetcher: jodFetcher, defaultFetcher: foodPlanFetcher)
        }
    }
}

struct DogsView: View {
    
    @EnvironmentObject var fetcher: Fetcher<Dog>
    
    
    @State var add: Bool = false

    
    var body: some View {
        List {
            ForEach(fetcher.data) { dog in
                SingleDogView(dog: dog, updated: $fetcher.updated)
                    .detailsDeleteSwipeable(
                        onDetails: {
                            fetcher.selected = dog
                        },
                        onDelete: {
                            fetcher.delete(dog)
                        })
            }
        }
        .emptyState($fetcher.data.isEmpty) {
            Text("No Dogs")
                .font(.title3)
                .foregroundColor(Color.secondary)
        }
        .sheet(item: $fetcher.selected) { data in
            NavigationView {
                DogEditView(data.toEdog()) { update in
                    fetcher.save(update, data)
                }
                .navigationTitle("Details")
            }
        }
        
        .sheet(isPresented: $add) {
            NavigationView {
                DogEditView(EDog.new()) { update in
                    fetcher.save(update, nil)
                }
                .navigationTitle("Add")
            }
        }
        
        .navigationTitle("Dogs")
        .toolbar{
            HStack {
                Button(action: { add = true }) {
                    Image(systemName: "plus.app")
                }
                
                
                
            }
        }
    }
}
