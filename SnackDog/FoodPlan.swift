import SwiftUI

extension EDog {
    func toBCDDogAlgaePowder()  -> (bcd_dog, bcd_algae_powder) {
        let d = self
        let bd = d.birthDate
        let components = Calendar.current
            .dateComponents([.day], from: bd, to: Date())
        let example_dog = bcd_dog(
            size: d.size,
            age: UInt32(components.day ?? 0 ),
            age_unit: bcd_day,
            weight: Float(d.weight.value),
            weight_unit: bcd_weight_unit(UInt32(d.weight.unit.toBCDUnit())),
            activity_level_in_hours: UInt32(d.activityHours),
            is_nautered: Int32(d.isNautered ? 1 : 0 ),
            is_old: Int32(d.isOld ? 1 : 0)
        )
        
        let example_algae_poweder = bcd_algae_powder(
            jod: UInt32(d.jod.value),
            per: UInt32(d.jodPer.value),
            jod_weight_unit: bcd_weight_unit(UInt32(d.jod.unit.toBCDUnit())),
            per_unit: bcd_weight_unit(UInt32(d.jodPer.unit.toBCDUnit()))
        )
        
        return (example_dog, example_algae_poweder)
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
                Text("\(t.value.printround(to: 2))") + Text(" \(t.unit.symbol)").foregroundColor(.secondary)
            }
        }
        
        GroupBox(label: label){
            VStack(alignment: .leading, spacing: 1.0) {
                ForEach(values.indices) { i in
                    let v = values[i]
                    HStack {
                        Text("\(v.name)")
                        Spacer()
                        Text("\(v.value.value.printround(to: 2))") + Text(" \(v.value.unit.symbol)").foregroundColor(.secondary)
                        
                    }.padding(.leading)
                }
            }
        }
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
    
    private func food_plan(t: (bcd_dog, bcd_algae_powder), ppd: UInt32) -> FoodPlan {
        var dog = t.0
        var ap = t.1
        
        let ptr = calculate_recommendation(&dog, &ap)
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
    
    var body: some View {
        // For now add a weekly overview in the list
        let weekdays = (DateFormatter().weekdaySymbols ?? []) + [ "Weekly" ]
        let fp = food_plan(t: dog.toBCDDogAlgaePowder(), ppd: 2)
        
        return TabView(selection: $pageIndex) {
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
        
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .toolbar{
            HStack {
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
        let dog = Dog(context: vc)
        PersistenceController.ExtendDog(newItem: dog, i: 1)
        return FoodPlan(dog: dog.toEdog())
    }
}
