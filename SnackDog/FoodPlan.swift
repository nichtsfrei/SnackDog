import SwiftUI

extension EDog {
    func toBCDDogAlgaePowder()  -> bcd_dog {
        let d = self
        let bd = d.birthDate
        
        let components = Calendar.current
            .dateComponents([.day], from: bd, to: Date())
        
        return bcd_dog(
            size: d.size,
            age: UInt32(components.day ?? 0 ),
            age_unit: bcd_day,
            weight: Float(d.weight.value),
            weight_unit: d.weight.unit.toBCDUnit(),
            activity_level_in_hours: UInt32(d.activityHours),
            is_nautered: Int32(d.isNautered ? 1 : 0 ),
            is_old: Int32(d.isOld ? 1 : 0)
        )
        
    }
}

extension JodData {
    func toBCD() -> bcd_algae_powder {
        if let val = value?.measurement() {
            if let per = per?.measurement() {
                return bcd_algae_powder(
                    jod: UInt32(val.value),
                    per: UInt32(per.value),
                    jod_weight_unit: val.unit.toBCDUnit(),
                    per_unit: per.unit.toBCDUnit()
                )
            }
        }
        return bcd_algae_powder(jod: 0,
                                per: 0,
                                jod_weight_unit: bcd_kilo_gram,
                                per_unit: bcd_kilo_gram
        )
        
    }
}

fileprivate struct Recommendation <T: Unit>{
    var name: String
    var value: Measurement<T>
}

fileprivate struct RecommendationView: View {
    var title: String
    var values: Array<Recommendation<UnitMass>>
    var total: Measurement<UnitMass>?
    
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
                ForEach(values.indices) { i in
                    let v = values[i]
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

extension bcd_algae_powder: Equatable, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(jod)
        hasher.combine(per)
        hasher.combine(jod_weight_unit.rawValue)
        hasher.combine(per_unit.rawValue)
    }
    
    
    public static func == (lhs: bcd_algae_powder, rhs: bcd_algae_powder) -> Bool {
        return lhs.jod == rhs.jod &&
        lhs.per == rhs.per &&
        lhs.jod_weight_unit.rawValue == rhs.jod_weight_unit.rawValue &&
        lhs.per_unit.rawValue == rhs.per_unit.rawValue
    }
    
    
}

struct FoodPlan: View {
    
    fileprivate struct Portion: Identifiable {
        var animal: Array<Recommendation<UnitMass>>
        var herbal: Array<Recommendation<UnitMass>>
        var supplements: Array<Recommendation<UnitMass>>
        var index: Int
        var id = UUID()
    }
    
    fileprivate struct FoodPlan {
        var days: Array<Array<Portion>>
        var dog: bcd_dog
        var weekly: Portion
    }
    
    let dog: EDog
    
    @State var jod: bcd_algae_powder
    var jodData: [JodData]
    
    
    
    
    func to_highest_mass(m: Measurement<UnitMass>) -> Measurement<UnitMass> {
        let val = m.value
        if val < 1000{
            return m
        }
        if val < 1000 * 1000 {
            return m.converted(to: UnitMass.milligrams)
        }
        if val < 1000 * 1000 * 1000 {
            return m.converted(to: UnitMass.grams)
        }
        return m.converted(to: UnitMass.kilograms)
    }
    
    private func herbal_to_recommendation_array(herbal: UnsafeMutablePointer<bcd_herbal_recommendations>?) -> Array<Recommendation<UnitMass>> {
        guard let h_ptr = herbal?.pointee else {
            return []
        }
        let p_len = h_ptr.len
        let len = Int(p_len)
        var result: Array<Recommendation<UnitMass>> = []
        for i in 0..<len {
            let rec = h_ptr.recommendations[i]
            let h_name = String(cString: bcd_herbal_type_string(rec.type))
            let amount = Double(rec.amount)
            let initial = Measurement(value: amount, unit: UnitMass.micrograms)
            
            let measurement: Measurement<UnitMass> = to_highest_mass(m: initial)
            let recommendation = Recommendation<UnitMass> (name: h_name, value: measurement)
            result.append(recommendation)
        }
        return result
    }
    
    private func animal_to_recommendation_array(animal: UnsafeMutablePointer<bcd_animal_recommendations>?) -> Array<Recommendation<UnitMass>> {
        guard let h_ptr = animal?.pointee else {
            return []
        }
        let p_len = h_ptr.len
        let len = Int(p_len)
        var result: Array<Recommendation<UnitMass>> = []
        for i in 0..<len {
            let rec = h_ptr.recommendations[i]
            let h_name = String(cString: bcd_animal_type_string(rec.type))
            let amount = Double(rec.amount)
            let initial = Measurement(value: amount, unit: UnitMass.micrograms)
            
            let measurement: Measurement<UnitMass> = to_highest_mass(m: initial)
            let recommendation = Recommendation<UnitMass> (name: h_name, value: measurement)
            result.append(recommendation)
        }
        return result
    }
    
    private func supplement_to_recommendation_array(supplements: UnsafeMutablePointer<bcd_supplement_recommendations>?) -> Array<Recommendation<UnitMass>> {
        guard let h_ptr = supplements?.pointee else {
            return []
        }
        let p_len = h_ptr.len
        let len = Int(p_len)
        var result: Array<Recommendation<UnitMass>> = []
        for i in 0..<len {
            let rec = h_ptr.recommendations[i]
            let h_name = String(cString: bcd_supplement_type_string(rec.type))
            let amount = Double(rec.amount)
            let initial = Measurement(value: amount, unit: UnitMass.micrograms)
            
            let measurement: Measurement<UnitMass> = to_highest_mass(m: initial)
            let recommendation = Recommendation<UnitMass> (name: h_name, value: measurement)
            result.append(recommendation)
        }
        return result
    }
    
    private func food_plan(dog: bcd_dog, ap: bcd_algae_powder, ppd: UInt32) -> FoodPlan {
        var d = dog
        var a = ap
        
        let ptr = calculate_recommendation(&d, &a)
        bcd_recommendation_for_span(1, bcd_week, ptr)
        
        let portions = bcd_food_plan(1, bcd_week, ppd, ptr)
        let p_r = portions?.pointee.recommendations
        let p_r_len = Int(p_r?.pointee.len ?? 0)
        var days: Array<Array<Portion>> = []
        
        for i in 0..<p_r_len {
            let rec = p_r?.pointee.recommendations[i]
            var day: Array<Portion> = []
            if i % Int(ppd) != 0 {
                day = days.last ?? []
            }
            let rh = rec?.herbal
            let h_r = herbal_to_recommendation_array(herbal: rh)
            
            let ra = rec?.animal
            let h_a = animal_to_recommendation_array(animal: ra)
            
            let rs = rec?.supplements
            let hs = supplement_to_recommendation_array(supplements: rs)
            
            let pIndex = i % Int(ppd)
            let portion = Portion(animal: h_a, herbal: h_r, supplements: hs, index: pIndex)
            day.append(portion)
            
            if i == 0 || pIndex == 0 {
                days.append(day)
            } else {
                days[days.count - 1] = day
            }
        }
        bcd_recommendation_for_span(1, bcd_week, ptr)
        let weekly = Portion(
            animal: animal_to_recommendation_array(animal: ptr?.pointee.animal),
            herbal: herbal_to_recommendation_array(herbal: ptr?.pointee.herbal),
            supplements: supplement_to_recommendation_array(supplements: ptr?.pointee.supplements),
            index: 0
        )
        
        
        bcd_destroy_portions_s(portions)
        bcd_destroy_recommendation_s(ptr)
        
        return FoodPlan(days: days, dog: dog, weekly: weekly)
    }
    
    private let total_rec = {(x: Measurement<UnitMass>, y: Recommendation<UnitMass>) -> Measurement<UnitMass> in
        let m: Measurement<UnitMass> = y.value.converted(to: x.unit)
        return Measurement(value: x.value + m.value, unit: x.unit)
    }
    let init_m = {Measurement(value: 0.0, unit: UnitMass.micrograms)}
    
    
    
    private func portionView(p: Portion) -> some View {
        
        let h_total = to_highest_mass(m: p.herbal.reduce(init_m(), total_rec))
        let a_total = to_highest_mass(m: p.animal.reduce(init_m(), total_rec))
        return VStack(alignment: .leading){
            RecommendationView(title: "🥗 Herbal", values: p.herbal, total: h_total)
            RecommendationView(title: "🥩 Animal", values: p.animal, total: a_total)
            RecommendationView(title: "💊 Supplements", values: p.supplements, total: nil)
        }
        
    }
    
    private func recomendationDayView(day: Array<Portion>) -> some View {
        
        
        return ForEach(day) { p in
            GroupBox("\(p.index + 1). Portion"){
                portionView(p: p)
            }
        }
    }
    
    private func weekDayToRecomendationIndex(d: Int) -> Int {
        if d == 0 {
            return 6
        }
        return d - 1
    }
    
    private func recommendationIndexToWeekDay(d: Int) -> Int {
        if d == 6 {
            return 0
        }
        return d + 1
    }
    
    @State var pageIndex = Calendar.current.component(.weekday, from: Date()) - 1
    
    private func jodText(jod: JodData) -> Text {
        let jm = jod.value?.measurement() ?? Measurement(value: 0, unit: .milligrams)
        let jp = jod.per?.measurement() ?? Measurement(value: 0, unit: .kilograms)
        return Text("\(jod.name ?? "") (") +
        Text(jm.formatted(.measurement(width: .narrow))) +
        Text(" / ").foregroundColor(.secondary) +
        Text(jp.formatted(.measurement(width: .narrow))) +
        Text(")")
    }
    
    init(dog: EDog, jodData: [JodData]) {
        self.dog = dog
        self.jodData = jodData
        self._jod = State(wrappedValue: jodData.first?.toBCD() ?? bcd_algae_powder(jod: 631, per: 1, jod_weight_unit: bcd_milli_gram, per_unit: bcd_kilo_gram))
    }
    
    var body: some View {
        // For now add a weekly overview in the list
        let weekdays = (DateFormatter().weekdaySymbols ?? []) + [ "Weekly" ]
        
        let fp = food_plan(dog: dog.toBCDDogAlgaePowder(),
                           ap: jod ,
                           ppd: 2)
        
        return VStack(alignment: .leading){
            TabView(selection: $pageIndex) {
                ForEach(weekdays.indices){ index in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(weekdays[index]).padding(.leading)
                            if index != weekdays.count - 1 {
                                let i = weekDayToRecomendationIndex(d: index)
                                recomendationDayView(day: fp.days[i])
                            } else {
                                portionView(p: fp.weekly)
                            }
                        }
                    }.tag(index)
                }
            }
        }
        
        .navigationTitle(dog.name)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .toolbar{
            HStack {
                if !jodData.isEmpty {
                Menu{
                        Menu("Algae Powder") {
                            
                            Picker("Algae Powder", selection: $jod) {
                                ForEach(jodData) {
                                    jodText(jod: $0).tag($0.toBCD())
                                }
                            }
                        }.pickerStyle(.automatic)
                    
                    
                } label: {
                    Image(systemName: "gear")
                }
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
            FoodPlan(dog: dog.toEdog(), jodData: [jod])
        }
    }
}
