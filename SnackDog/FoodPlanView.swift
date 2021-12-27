import SwiftUI

fileprivate struct RecommendationView: Identifiable, View {
    var id: Int
    var title: String
    var values: Array<Recommendation<UnitMass>>
    var total: Measurement<UnitMass>?
    
    init (id: Int, title: String, values: Array<Recommendation<UnitMass>>, total: Measurement<UnitMass>) {
        self.id = id
        self.title = title
        self.values = values
        self.total = total
    }
    
    var body: some View {
        let label = HStack{
            Text(title)
            Spacer()
            if let t = total {
                Text(t.formatted(.measurement(width: .abbreviated)))
            }
        }
        
        GroupBox(label: label){
            VStack(alignment: .leading, spacing: 1.0) {
                ForEach(values) { v in
                    HStack {
                        Text("\(v.name)")
                        Spacer()
                        Text(v.value.formatted(.measurement(width: .abbreviated)))
                        
                    }.padding(.leading)
                }
            }
        }
    }
    
}

struct AlgaePowder: Identifiable, Hashable {
    let id: UUID
    let name: String
    
    let jod: Measurement<UnitMass>
    let per: Measurement<UnitMass>
    
    
    static func from(jodData: JodData?) -> AlgaePowder {
        return AlgaePowder(
            id: jodData?.id ?? UUID(),
            name: jodData?.name ?? "Default",
            jod: jodData?.value?.measurement() ?? Measurement(value: 631, unit: .milligrams),
            per: jodData?.per?.measurement() ?? Measurement(value: 1, unit: .kilograms)
        )
    }
}

struct FoodPlanView: View {
    
    let dog: EDog
    let basePlans: [FoodBasePlan] = [ .summarizedInsides, .separatedInsides]
    @State var plan: FoodBasePlan = .separatedInsides
    
    @State var jod: AlgaePowder
    var jodData: [AlgaePowder]
    let weekdays = (DateFormatter().weekdaySymbols ?? []) + [ "Weekly" ]
    
    
    
    private let total_rec = {(x: Measurement<UnitMass>, y: Recommendation<UnitMass>) -> Measurement<UnitMass> in
        let m: Measurement<UnitMass> = y.value.converted(to: x.unit)
        return Measurement(value: x.value + m.value, unit: x.unit)
    }
    let init_m = {Measurement(value: 0.0, unit: UnitMass.micrograms)}
    
    private func portionView(p: Portion) -> some View {
        let views = { () -> [RecommendationView] in
            let gCategories = Dictionary(grouping: p.recommendation) {
                $0.category
            }
            
            
            return gCategories.map { c in
                RecommendationView(
                    id: c.value.first?.index ?? c.key.hash,
                    title: c.key,
                    values: c.value,
                    total: c.value.reduce(init_m(), total_rec))
            }.sorted{ a, b in
                a.id < b.id
                
            }
        }
        return VStack(alignment: .leading){
            
            ForEach(views()) {
                $0
            }
        }
        
    }
    
    private func recomendationDayView(day: Array<Portion>) -> some View {
        
        
        return ForEach(day) { p in
            GroupBox("\(p.index + 1). Portion"){
                portionView(p: p)
            }
        }
    }
    
    
    @State var pageIndex = Calendar.current.component(.weekday, from: Date()) - 1
    
    private func jodText(jod: AlgaePowder) -> Text {
       
        return Text("\(jod.name) (") +
        Text(jod.jod.formatted(.measurement(width: .narrow))) +
        Text(" / ").foregroundColor(.secondary) +
        Text(jod.per.formatted(.measurement(width: .narrow))) +
        Text(")")
    }
    
    init(dog: EDog, jodData: [JodData]) {
        self.dog = dog
        self.jodData = jodData.map { AlgaePowder.from(jodData: $0)}
        self._jod = State(wrappedValue: AlgaePowder.from(jodData: jodData.first))
    }
    
    var body: some View {
        // For now add a weekly overview in the list
        
        let fp = FoodCalculation(
            dog: dog,
            jd: jod,
            plan: plan).calculate()
        
        return VStack(alignment: .leading){
            TabView(selection: $pageIndex) {
                ForEach(weekdays.indices){ index in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(weekdays[index]).padding(.leading)
                            if index != weekdays.count - 1 {
                                let filtered: [Portion] = fp.days[index].filter { d in
                                    return d != nil
                                }.map{ d in
                                    return d!
                                }
                                recomendationDayView(day: filtered)
                            } else {
                                portionView(p: fp.weekly)
                            }
                        }
                    }.tag(index)
                }
            }
        }
        
        .navigationTitle("\(dog.name)")
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .toolbar{
            HStack {
                Menu{
                    if !jodData.isEmpty {
                        Menu("Algae Powder") {
                            
                            Picker("Algae Powder", selection: $jod) {
                                ForEach(jodData) {
                                    jodText(jod: $0).tag($0)
                                }
                            }
                        }.pickerStyle(.automatic)
                    }
                    Menu("Plan") {
                        Picker("Plan", selection: $plan) {
                            ForEach(basePlans) {
                                Text($0.name).tag($0)
                            }
                        }
                    }
                    
                } label: {
                    Image(systemName: "gear")
                }
                
                
                Button(action: {
                    pageIndex = Calendar.current.component(.weekday, from: Date()) - 1
                }){
                    Image(systemName: "calendar")
                }
                Button(action: {
                    pageIndex = weekdays.count - 1
                }){
                    Image(systemName: "list.bullet")
                }
                
                
                
            }
        }
        
    }
}

struct FoodPlan_Previews: PreviewProvider {
    static var previews: some View {
        
        let vc = PersistenceController.preview.container.viewContext
        let dog = PersistenceController.NewDog(vc: vc, i: 1)
        let value = MeasurementData(context: vc)
        value.id = UUID()
        value.value = 631
        value.symbol = "mg"
        let per = MeasurementData(context: vc)
        per.id = UUID()
        per.value = 1
        per.symbol = "kg"
        
        let jod = JodData(context: vc)
        
        jod.name = "test"
        jod.value = value
        jod.per = per
        return NavigationView {
            FoodPlanView(dog: dog.toEdog(), jodData: [jod])
        }
    }
}
