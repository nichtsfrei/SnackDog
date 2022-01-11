import SwiftUI

fileprivate struct RecommendationView: Identifiable, View {
    var id: Int
    var title: LocalizedStringKey
    var symbol: String
    var values: Array<Recommendation<UnitMass>>
    var total: Measurement<UnitMass>?
    
    init (id: Int, title: String, symbol: String, values: Array<Recommendation<UnitMass>>, total: Measurement<UnitMass>) {
        self.id = id
        self.title = LocalizedStringKey(title)
        self.values = values
        self.total = total
        self.symbol = symbol
    }
    
    var body: some View {
        let label = HStack{
            Text(symbol) + Text(title)
            Spacer()
            if let t = total {
                Text(t.formatted(.measurement(width: .abbreviated)))
            }
        }
        
        GroupBox(label: label){
            VStack(alignment: .leading, spacing: 1.0) {
                ForEach(values) { v in
                    HStack {
                        Text(LocalizedStringKey(v.name))
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
    @State var defaultFetcher: Fetcher<FoodPlanData>
    
    let basePlans: [FoodBasePlan] = [
        .summarizedInsides,
        .summarizedInsidesOnlyWeakBones,
        .separatedInsides,
        .separatedInsidesOnlyWeakBones
    ]
    let weekdays = Locale.current.calendar.weekdaySymbols
    
    let dog: EDog
    @State var plan: FoodBasePlan
    
    @State var portions: Int
    
    @State var jod: AlgaePowder
    
    @State var showWeekly: Bool = false
    let defaults: FoodPlanData?
    let todaysIndex = Calendar.current.component(.weekday, from: Date()) - 1
    
    
    
    init(dog: EDog, fetcher: Fetcher<JodData>, defaultFetcher: Fetcher<FoodPlanData>) {
        self.dog = dog
        let defaults = defaultFetcher.data.first{
            if let dID = $0.dog {
                return dID == dog.id
            }
            return false
        }
        let startingJodData = fetcher.data.first{
            return $0.id == defaults?.jodData
        } ?? fetcher.data.first
        let baseplan = basePlans.first{
            return $0.id == defaults?.basePlan
        } ?? .summarizedInsides
        self._jod = State(wrappedValue: AlgaePowder.from(jodData: startingJodData))
        self._fetcher = State(wrappedValue: fetcher)
        self._portions = State(wrappedValue: Int(defaults?.portions ?? 2))
        self._defaultFetcher = State(wrappedValue: defaultFetcher)
        self._plan = State(wrappedValue: baseplan)
        self.defaults = defaults
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
                    symbol: c.value.first?.symbol ?? "",
                    values: c.value,
                    total: c.value.reduce(init_m(), total_rec))
            }.sorted{ a, b in
                a.id < b.id
                
            }
        }
        return ForEach(views()) {
                $0
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
    
    private func getOrCreate(_ d: FoodPlanData?) -> FoodPlanData {
        if let result = d {
            return result
        }
        return defaultFetcher.withConext{
            return  FoodPlanData(context: $0)
        }
    }
    
    func saveDefaults() {
        let fpd = getOrCreate(defaults)
        
        fpd.dog = dog.id
        fpd.basePlan = plan.id
        fpd.portions = Int16(portions)
        fpd.jodData = jod.id
        
        defaultFetcher.save()
    }
    
    var body: some View {
        
        let fp = FoodCalculation(
            dog: dog,
            jd: jod,
            plan: plan,
            portions: portions).calculate()
        
        return VStack(alignment: .leading){
            HStack {
                (Text("Plan: ") + Text(LocalizedStringKey(plan.name)))
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .padding(.leading).foregroundColor(.secondary).font(.footnote)
                Spacer()
                Text("Algae Powder: \(jod.name)")
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .padding(.leading).foregroundColor(.secondary).font(.footnote)
            }
            
            TabView(selection: $pageIndex) {
                ForEach(weekdays.indices){ index in
                    VStack(alignment: .leading) {
                        Text(weekdays[index])
                            .padding(.leading)
                            .font(.title2)
                            .foregroundColor(todaysIndex == index ? .primary : .secondary)
                        ScrollView {
                            
                            let filtered: [Portion] = fp.days[index].filter { d in
                                return d != nil
                            }.map{ d in
                                return d!
                            }
                            recomendationDayView(day: filtered)
                            
                        }
                    }.tag(index)
                }
            }
        }
        
        .navigationTitle("\(dog.name)")
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .onChange(of: portions) { _ in
            saveDefaults()
        }
        .onChange(of: jod) { _ in
            saveDefaults()
        }
        .onChange(of: plan) { _ in
            saveDefaults()
        }
        .sheet(isPresented: $showWeekly) {
                VStack {
                    Text("Weekly").font(.title2).padding()
                    portionView(p: fp.weekly)
                    Spacer()
                }
            
        }
        .toolbar{
            HStack {
                Button(action: {
                    showWeekly = true
                }){
                    Image(systemName: "list.bullet")
                }
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
                    Menu("Portions") {
                        Picker("Portions", selection: $portions) {
                            ForEach(1..<5) {
                                Text("\($0)").tag($0)
                            }
                        }
                    }
                    Menu("Plan") {
                        Picker("Plan", selection: $plan) {
                            ForEach(basePlans) {
                                Text(LocalizedStringKey($0.name)).tag($0)
                            }
                        }
                    }
                    
                } label: {
                    Image(systemName: "gear")
                }
                
                
            }
        }
        
    }
}

