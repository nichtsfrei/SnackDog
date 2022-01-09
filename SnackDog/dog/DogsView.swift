import SwiftUI




fileprivate struct SingleDogView: View {
    
    @State var dog: Dog
    @Binding var updated: Dog?
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
    
    func measurementData(md: MeasurementData?) -> MeasurementData {
        return self.withConext{ context in
            let result = MeasurementData(context: context)
            result.id = md?.id ?? UUID()
            return result
        }
        
    }
    
    func save(_ changed: EDog, _ basedOn: Dog?) -> Dog {
        let result: Dog = self.withConext{ context in
            let dog = Dog(context: context)
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
            return dog
        }
        let _ = self.save()
        return result
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
    
    @State var updated: Dog? = nil
    @State var details: Dog? = nil
    @State var add: Bool = false

    
    var body: some View {
        List {
            ForEach(fetcher.data) { dog in
                SingleDogView(dog: dog, updated: $updated)
                    .detailsDeleteSwipeable(
                        onDetails: {
                            details = dog
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
        .sheet(item: $details) { data in
            NavigationView {
                DogEditView(data.toEdog()) { update in
                    updated = fetcher.save(update, data)
                    
                }
                .navigationTitle("Details")
            }
        }
        
        .sheet(isPresented: $add) {
            NavigationView {
                DogEditView(EDog.new()) { update in
                    updated = fetcher.save(update, nil)
                    
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
