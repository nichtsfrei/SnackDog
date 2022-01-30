import Foundation

struct Recommendation <T: Dimension>: Identifiable{
    // TODO add complete category
    var id: UUID = UUID()
    var name: String
    var symbol: String
    var category: String
    var index: Int
    var value: Measurement<T>
}

struct Portion: Identifiable {
    var recommendation: Array<Recommendation<Dimension>>
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
    let jodSource: AlgaePowder
    let days: Int
    let portions: Int
    
    init(dog: EDog, jd: AlgaePowder, plan: FoodBasePlan, portions: Int = 2) {
        self.dog = dog
        self.plan = plan
        self.days = 7
        self.jodSource = jd
        self.portions = portions
    }
    

    private func portion(days: Int) -> Portion {
        
        let recommendations: [Recommendation<Dimension>] = plan.needs.map{
            guard var amount = perDay($0) else {
                return Recommendation(name: $0.name, symbol: $0.category.symbol, category: $0.category.name, index: $0.category.sortIndex, value: Measurement(value: 0, unit: UnitMass.kilograms))
            }
            amount.value *= Double(days)
            return Recommendation(name: $0.name, symbol: $0.category.symbol, category: $0.category.name, index: $0.category.sortIndex, value: amount)
        }
        
        return Portion(recommendation: recommendations, index: 0)
    }
    
    private func perDay(_ need: Need<Dimension>) -> Measurement<Dimension>? {
        
        return need.proportions.map{ a in
            return a.calculate(category: need.category, dog: dog)
        }.filter{ a in
            a != nil
        }.map{
            $0!
        }.first
    }
    
    func calculate() -> FoodPlan {
        let emptyPortions = { (amount: Int) -> [Portion?] in
            return (0..<amount).map{ _ in
                return nil
            }
        }
        
        var result: [[Portion?]] = (0..<days).map { _ in
            return emptyPortions(portions)
        }
        
        for i in plan.needs {
            
            guard let perDay = perDay(i) else {
                continue
            }
            
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
                    var rname = i.name
                    // handle different sources of a need more elgantly than now
                    if i.name == "jod" {
                        let jsp = jodSource.jod.converted(to: .grams).value / jodSource.per.converted(to: .grams).value
                        perPortion.value = perPortion.value / jsp
                        rname = "algae powder"
                    }
                    
                    let recommendation = Recommendation(name: rname, symbol: i.category.symbol, category: i.category.name, index: i.category.sortIndex, value: perPortion)
                    if pToAppend == nil {
                        pToAppend = Portion(recommendation: [recommendation], index: portion)
                    } else {
                        pToAppend?.recommendation.append(recommendation)
                    }
                    
                    result[day][pIndex] = pToAppend
                }
            }
            
        }
        return FoodPlan(days: result, dog: dog, weekly: portion(days: 7))
        
        
        
        
    }
    
    
}


