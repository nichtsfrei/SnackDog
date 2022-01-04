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



struct FoodPlanView: View {
    
    @State var fetcher: Fetcher<JodData>
    
    let basePlans: [FoodBasePlan] = [
        .summarizedInsides,
        .summarizedInsidesOnlyWeakBones,
        .separatedInsides,
        .separatedInsidesOnlyWeakBones
    ]
    let weekdays = (DateFormatter().weekdaySymbols ?? []) + [ "Weekly" ]
    
    let dog: EDog
    @State var plan: FoodBasePlan = .summarizedInsides
    
    @State var jod: AlgaePowder?
    
    init(dog: EDog, fetcher: Fetcher<JodData>) {
        self.dog = dog
        self._jod = State(wrappedValue: AlgaePowder.from(jodData: fetcher.data.first))
        self._fetcher = State(wrappedValue: fetcher)
    }
    
    
    
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
    
    var body: some View {
        // For now add a weekly overview in the list
        let jd = jod ?? AlgaePowder.from(jodData: nil)
        let fp = FoodCalculation(
            dog: dog,
            jd: jd,
            plan: plan).calculate()
        
        return VStack(alignment: .leading){
            HStack {
                Text("Plan: \(plan.name)").padding(.leading).foregroundColor(.secondary).font(.footnote)
                Spacer()
                Text("Algae Powder: \(jd.name)").padding(.leading).foregroundColor(.secondary).font(.footnote)
            }

            TabView(selection: $pageIndex) {
                ForEach(weekdays.indices){ index in
                    VStack(alignment: .leading) {
                        Text(weekdays[index]).padding(.leading).font(.title2)
                        ScrollView {
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
                    if !fetcher.data.isEmpty {
                        Menu("Algae Powder") {
                            
                            Picker("Algae Powder", selection: $jod) {
                                ForEach(fetcher.data) {
                                    jodText(jod: AlgaePowder.from(jodData: $0)).tag(AlgaePowder.from(jodData: $0) as AlgaePowder?)
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

