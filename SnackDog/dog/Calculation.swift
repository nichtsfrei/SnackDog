import Foundation

struct Recommendation <T: Unit>: Identifiable{
    var id: UUID = UUID()
    var name: String
    var symbol: String
    var category: String
    var index: Int
    var value: Measurement<T>
}

struct Portion: Identifiable {
    var recommendation: Array<Recommendation<UnitMass>>
    var index: Int
    var id = UUID()
}

struct FoodPlan {
    var days: Array<Array<Portion?>>
    var dog: EDog
    var weekly: Portion
}

class FoodCalculation {
    
    let dog: EDog
    let plan: FoodBasePlan
    let jd: AlgaePowder
    let days: Int
    let portions: Int
    
    init(dog: EDog, jd: AlgaePowder, plan: FoodBasePlan, portions: Int = 2) {
        self.dog = dog
        self.plan = plan
        self.days = 7
        self.jd = jd
        self.portions = portions
    }
    
    func jodPercentageForAge(birthDate: Date) -> Double {
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: birthDate , to: Date()).month!
        let jodMicroGram: Double = {
            switch months {
            case _ where months < 4:
                return 29.0
            case _ where months < 7:
                return 29.0 * 0.9
            case _ where months < 10:
                return 29.0 * 0.8
            case _ where months < 12:
                return 29.0 * 0.7
            case _ where months < 14:
                return 29.0 * 0.6
            case _ where months < 16:
                return 29.0 * 0.5
            default:
                return 12.7
            }
        }()
        return jodMicroGram / Measurement(value: 1, unit: UnitMass.kilograms).converted(to: .micrograms).value
    }
    
    func algae_powder_per_day(birthDate: Date, weight: Measurement<UnitMass>, jd: AlgaePowder) -> Measurement<UnitMass> {
        let jod_algae_percent = jd.jod.converted(to: .micrograms).value / jd.per.converted(to: .micrograms).value
        let jodPercent = jodPercentageForAge(birthDate: birthDate)
        var jod = weight.converted(to: .micrograms)
        jod.value = jod.value * jodPercent / jod_algae_percent
        return jod
    }
    
    func need(_ fpd: Double, _ i: Need) -> Measurement<UnitMass> {
        if i.automatic && i.id == Need.algaePowder.id {
            return algae_powder_per_day(birthDate: dog.birthDate, weight: dog.weight, jd: jd).converted(to: .micrograms)
        }
        if i.basedOn == 0 {
            return Measurement(value: fpd * i.category.percentage * i.percentage, unit: .micrograms)
        }
        return Measurement(value: fpd * i.percentage, unit: .micrograms)
    }
    
    
    
    func portion(fpd: Double, days: Int) -> Portion {
        
        let recommendations: [Recommendation<UnitMass>] = plan.needs.map{
            var amount = need(fpd, $0)
            amount.value *= Double(days)
            return Recommendation(name: $0.name, symbol: $0.category.symbol, category: $0.category.name, index: $0.category.id, value: amount)
        }
        
        return Portion(recommendation: recommendations, index: 0)
    }
    
    
    
    func calculate() -> FoodPlan {
        let fpd = dog.weight.converted(to: .micrograms).value * dog.factor()
        let emptyPortions = { (amount: Int) -> [Portion?] in
            return (0..<amount).map{ _ in
                return nil
            }
        }
        
        var result: [[Portion?]] = (0..<days).map { _ in
            return emptyPortions(portions)
        }
        
        for i in plan.needs {
            let perDay = need(fpd, i)
            let cd = i.days.isEmpty ? (0..<days).map{ d in return d} : i.days
            let cp = i.portions.isEmpty ? (0..<portions).map{ p in return p} : i.portions
            for day in cd {
                let toAppend = result[day]
                for portion in cp {
                    let pIndex = portion < toAppend.endIndex ? portion : toAppend.endIndex - 1
                    var pToAppend = toAppend[pIndex]
                    var perPortion = perDay
                    
                    perPortion.value = perPortion.value * Double(days / cd.count)
                    if cp.count == portions {
                        perPortion.value = perPortion.value / Double(portions)
                    }
                    let recommendation = Recommendation(name: i.name, symbol: i.category.symbol, category: i.category.name, index: i.category.id, value: perPortion)
                    if pToAppend == nil {
                        pToAppend = Portion(recommendation: [recommendation], index: portion)
                    } else {
                        pToAppend?.recommendation.append(recommendation)
                    }
                    
                    result[day][pIndex] = pToAppend
                }
            }
            
        }
        return FoodPlan(days: result, dog: dog, weekly: portion(fpd: fpd, days: 7))
        
        
        
        
    }
    
    
}


