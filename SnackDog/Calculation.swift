//
//  Calculation.swift
//  SnackDog
//
//  Created by Philipp on 26.12.21.
//

import SwiftUI

enum DogSize: String, Hashable {
    case small, medium, large
    
}

extension DogSize {
    func factor(_ birthDate: Date) -> Double {
        return DogSizeFactor.byDogSize(self).factor(birthDate)
    }
}

class DogSizeFactor {
    let factor: [(Calendar.Component?, Int, Double)]
    init(factor: [(Calendar.Component?, Int, Double)]) {
        self.factor = factor
    }
    
    func factor(_ birthDate: Date) -> Double {
        let calendar = Calendar.current
        let now = Date()
        for t in factor {
            if let compontent = t.0 {
                let age = calendar.dateComponents([compontent], from: now).value(for: compontent)!
                if age < t.1 {
                    return t.2
                }
            } else {
                return t.2
            }
        }
        return factor.last?.2 ?? 0.02
    }
    
    static let small = DogSizeFactor(factor: [
        (.weekOfYear, 16, 0.051),
        (.weekOfYear, 24, 0.045),
        (.month, 10, 0.032),
        (nil, 0, 0.03),
    ])
    
    static let medium = DogSizeFactor(factor:[
        (.weekOfYear, 16, 0.054),
        (.weekOfYear, 24, 0.048),
        (.weekOfYear, 34, 0.038),
        (.month, 12, 0.036),
        (.month, 18, 0.03),
        (nil, 0, 0.025),
    ])
    
    static let large = DogSizeFactor(factor: [
        (.weekOfYear, 16, 0.06),
        (.weekOfYear, 24, 0.054),
        (.weekOfYear, 38, 0.048),
        (.month, 16, 0.042),
        (.month, 24, 0.036),
        (nil, 0, 0.02),
    ])
    
    static let all = [DogSize.small: small, DogSize.medium: medium, DogSize.large: large]
    
    static func byDogSize(_ size: DogSize) -> DogSizeFactor {
        return .all[size] ?? .small
    }
    
}

extension EDog {
    
    fileprivate func activityFactor() -> Double {
        if (activityHours < 2 ){ return 1.0; }
        if (activityHours < 3 ){ return 1.25; }
        if (activityHours < 4 ){ return 1.5; }
        if (activityHours < 5 ){ return 1.75; }
        if (activityHours < 6 ){ return 2.0; }
        return 2.5;
    }
    
    fileprivate func baseFactor() -> Double {
        return size.factor(birthDate)
        
    }
    
    func factor() -> Double {
        var result = baseFactor() * activityFactor()
        if isOld {
            result *= 0.9
        }
        if isNautered {
            result *= 0.9
        }
        return result > 0.1 ? 0.1 : result
    }
    
    
    
    func algae_powder_per_day(jd: AlgaePowder) -> Measurement<UnitMass> {
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: birthDate , to: Date()).month!
        var jodPercent: Double = {
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
        
        jodPercent = jodPercent / Measurement(value: 1, unit: UnitMass.kilograms).converted(to: .micrograms).value
        let jod_algae_percent = jd.jod.converted(to: .micrograms).value / jd.per.converted(to: .micrograms).value
        var jod = weight.converted(to: .micrograms)
        jod.value = jod.value * jodPercent / jod_algae_percent
        return jod
    }
    
}

struct Category: Identifiable, Hashable {
    let id: Int
    let name: String
    let percentage: Double // Of food
    
    
    
    static let animal = Category(id: 0, name: "🥩 Animal", percentage: 0.8)
    static let herbal = Category(id: 1, name: "🥗 Herbal", percentage: 0.2)
    static let supplement = Category(id: 2, name: "💊 Supplements", percentage: 0)
    
}

class Need: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: Category
    let percentage: Double // if 0
    let basedOn: Int// 0 == of category; 1 == food per day
    let days: [Int] // Empty == each day and portion, 0 == Sunday, 1 == monday, .. Saturday == 6
    let portions: [Int] // Empty each portion; otherwise index of portions
    let automatic: Bool // use automatic function (currently just algae powder)
    
    init(id: UUID = UUID(),
         name: String,
         category: Category,
         percentage: Double,
         basedOn: Int = 0,
         days: [Int] = [],
         portions: [Int] = [],
         automatic: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.percentage = percentage
        self.basedOn = basedOn
        self.days = days
        self.portions = portions
        self.automatic = automatic
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(percentage)
        hasher.combine(basedOn)
        hasher.combine(days)
        hasher.combine(portions)
        hasher.combine(automatic)
    }
    
    func copy(
        id: UUID? = UUID(),
        name: String? = nil,
        category: Category? = nil ,
        percentage: Double? = nil,
        basedOn: Int? = nil,
        days: [Int]? = nil,
        portions: [Int]? = nil,
        automatic: Bool? = nil
    ) -> Need {
        let of = self
        return Need(
            id: id ?? of.id,
            name: name ?? of.name,
            category: category ?? of.category,
            percentage: percentage ?? of.percentage,
            basedOn: basedOn ?? of.basedOn,
            days: days ?? of.days,
            portions: portions ?? of.portions,
            automatic: automatic ?? of.automatic)
        
    }
    
    static func == (lhs: Need, rhs: Need) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.percentage == rhs.percentage &&
        lhs.basedOn == rhs.basedOn &&
        lhs.days == rhs.days &&
        lhs.portions == rhs.portions &&
        lhs.automatic == rhs.automatic
    }
    
    static let animal = Need(name: "animal", category: Category.animal, percentage: 0.8, basedOn: 1)
    static let scallop = Need(name: "scallop", category: Category.animal, percentage: 0.5)
    static let rumen = Need(name: "rumen", category: Category.animal, percentage: 0.2)
    static let bones = Need(name: "raw meaty bones", category: Category.animal, percentage: 0.15)
    // generic insides
    static let insides = Need(name: "insides", category: Category.animal, percentage: 0.15)
    // specific insides, when one is unavailable then it needs to be adjusted
    static let liver = Need(name: "liver", category: Category.animal, percentage: 0.15 * 0.4)
    static let lung = Need(name: "lung", category: Category.animal, percentage: 0.15 * 0.15)
    static let heart = Need(name: "heart", category: Category.animal, percentage: 0.15 * 0.15)
    static let kidney = Need(name: "kidney", category: Category.animal, percentage: 0.15 * 0.15)
    static let spleen = Need(name: "spleen", category: Category.animal, percentage: 0.15 * 0.15)
    
    
    static let vegetables = Need(name: "vegetables", category: Category.herbal, percentage: 0.8)
    static let fruits = Need(name: "fruits", category: Category.herbal, percentage: 0.2)
    static let algaePowder = Need(name: "algae powder", category: Category.supplement, percentage: 0.00000463, basedOn: 1, days: [1, 3, 5], portions: [0], automatic: true)
    static let codliverOild = Need(name: "cod liver oil", category: Category.supplement, percentage: 0.00000463, basedOn: 1, days: [2, 4, 6], portions: [0])
    static let omega3Oil = Need(name: "omega 3 oil", category: Category.supplement, percentage: 0.0000093, basedOn: 1, portions: [1])
    static let fat = Need(name: "fat", category: Category.supplement, percentage: 0.03, basedOn: 1, automatic: true)
    
}


class FoodBasePlan: Hashable, Identifiable {
    
    let id: UUID
    let name: String
    let needs: [Need]
    
    init(id: UUID = UUID(), name: String, needs: [Need]) {
        self.id = id
        self.needs = needs
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(needs)
    }
    
    static func == (lhs: FoodBasePlan, rhs: FoodBasePlan) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.needs == rhs.needs
    }
    
    static let summarizedInsides: FoodBasePlan = FoodBasePlan(name: "Summarized insides", needs: [
        .scallop,
        .rumen,
        .insides,
        .bones,
        .vegetables,
        .fruits,
        .algaePowder,
        .codliverOild,
        .omega3Oil,
        .fat,
    ])
    
    
    static func onlyWeakBones(basedOn: FoodBasePlan) -> FoodBasePlan {
        
        let needs: [Need] = basedOn.needs.map {
            
            if $0 == Need.rumen {
                return $0.copy(percentage:0.15)
            }
            if $0 == Need.bones {
                return $0.copy(percentage: 0.20)
            }
            return $0
        }
        return FoodBasePlan(name: "\(basedOn.name) only weak bones (e.g. chicken)", needs: needs)
    }
    static let summarizedInsidesOnlyWeakBones: FoodBasePlan = onlyWeakBones(basedOn: FoodBasePlan.summarizedInsides)
    
    static let separatedInsides: FoodBasePlan = FoodBasePlan(name: "Insides", needs: [
        .scallop,
        .rumen,
        .liver,
        .lung,
        .heart,
        .kidney,
        .spleen,
        .bones,
        .vegetables,
        .fruits,
        .algaePowder,
        .codliverOild,
        .omega3Oil,
        .fat,
    ])
    static let separatedInsidesOnlyWeakBones: FoodBasePlan = onlyWeakBones(basedOn: FoodBasePlan.separatedInsides)
}

struct Recommendation <T: Unit>: Identifiable{
    var id: UUID = UUID()
    var name: String
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
    
    func need(_ fpd: Double, _ i: Need) -> Measurement<UnitMass> {
        if i.automatic && i.id == Need.algaePowder.id {
            return dog.algae_powder_per_day(jd: jd).converted(to: .micrograms)
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
            return Recommendation(name: $0.name, category: $0.category.name, index: $0.category.id, value: amount)
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
                    var pToAppend = toAppend[portion]
                    var perPortion = perDay
                    
                    perPortion.value = perPortion.value * Double(days / cd.count)
                    if cp.count == portions {
                        perPortion.value = perPortion.value / Double(portions)
                    }
                    let recommendation = Recommendation(name: i.name, category: i.category.name, index: i.category.id, value: perPortion)
                    if pToAppend == nil {
                        pToAppend = Portion(recommendation: [recommendation], index: portion)
                    } else {
                        pToAppend?.recommendation.append(recommendation)
                    }
                    
                    result[day][portion] = pToAppend
                }
            }
            
        }
        return FoodPlan(days: result, dog: dog, weekly: portion(fpd: fpd, days: 7))
        
        
        
        
    }
    
    
}


