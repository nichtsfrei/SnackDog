import Foundation
import UIKit
import DeveloperToolsSupport

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
        
        return result > 0.06 ? 0.06 : result
    }
    
}

enum ProportionBasedOn: Equatable, Hashable {
    case category, weight
}

enum ProportionWhen: Equatable, Hashable {
    case unconditional, olderThan(months: Int), youngerThan(months: Int)
    
}

class Proportion<T: Unit>: Hashable {
    
    var divident: Measurement<T>
    var divisor: Measurement<T>
    var basedOn: ProportionBasedOn
    var when: ProportionWhen
    
    init(divident: Measurement<T>, divisor: Measurement<T>, basedOn: ProportionBasedOn = .category, when: ProportionWhen = .unconditional) {
        self.basedOn = basedOn
        self.divident = divident
        self.divisor = divisor
        self.when = when
    }
    
    private func selectReturnUnit(based: Dimension) -> Dimension {
        if based as? UnitMass != nil{
            return UnitMass.grams
        }
        return UnitVolume.milliliters
    }
    
    private func byMeasurement() -> Measurement<T>? {
        
        if let mass_divident = divident as? Measurement<Dimension> {
            if let mass_divisor = divisor as? Measurement<Dimension> {
                
                let unit = selectReturnUnit(based: mass_divident.unit)
                
                let result = mass_divident.converted(to: unit).value / mass_divisor.converted(to: unit).value
                return Measurement(value: result, unit: unit as! T)
            }
        }
        
        return nil
    }
    
    private func doesApply(dog: EDog) -> Bool {
        
        switch when {
        case .unconditional:
            return true
        case .olderThan(let months):
            let calendar = Calendar.current
            let dogAge = calendar.dateComponents([.month], from: dog.birthDate , to: Date()).month!
            return dogAge > months
        case .youngerThan(let months):
            let calendar = Calendar.current
            let dogAge = calendar.dateComponents([.month], from: dog.birthDate , to: Date()).month!
            return dogAge < months
        }
        
    }
    
    private func base(category: Category, dog: EDog) -> Double {
        let weight = dog.weight.converted(to: .grams).value
        switch basedOn {
        case .category:
            return category.percentage() * dog.factor() * weight
        case .weight:
            return weight
        }
    }
    
    func calculate(category: Category, dog: EDog) -> Measurement<T>? {
        guard doesApply(dog: dog)  else {
            return nil
        }
        guard var result = byMeasurement() else {
            return nil
        }
        
        result.value = result.value * base(category: category, dog: dog)
        return result
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(when)
        hasher.combine(basedOn)
        hasher.combine(divisor)
        hasher.combine(divident)
        
    }
    
    static func == (lhs: Proportion, rhs: Proportion) -> Bool {
        return lhs.when == rhs.when &&
        lhs.divisor == rhs.divisor &&
        lhs.divident == rhs.divident &&
        lhs.basedOn == rhs.basedOn
    }
}

struct Category: Identifiable, Hashable {
    let id: UUID = UUID()
    var sortIndex: Int
    var name: String
    var symbol: String
    
    var divident: Measurement<Dimension>
    var divisor: Measurement<Dimension>
    
    func percentage() -> Double {
        return divisor.value / divident.converted(to: divisor.unit).value
    }
    
    fileprivate static func createCategory(sortIndex: Int, name: String, symbol: String, percentage: Double) -> Category {
        return Category(sortIndex: sortIndex, name: name, symbol: symbol, divident: Measurement(value: 1, unit: UnitMass.kilograms), divisor: Measurement(value: 1000 * percentage, unit: UnitMass.grams))
    }
    
    static let animal = createCategory(sortIndex: 0, name: "Animal", symbol: "🥩", percentage: 0.8)
    static let herbal = createCategory(sortIndex: 1, name: "Herbal", symbol: "🥗", percentage: 0.2)
    static let supplement = createCategory(sortIndex: 2, name: "Supplements", symbol: "💊", percentage: 0)
    
}

class Need<T: Unit>: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: Category
    let proportions: [Proportion<T>]
    let days: [Int] // Empty == each day and portion, 0 == Sunday, 1 == monday, .. Saturday == 6
    let portions: [Int] // Empty each portion; otherwise index of portions
    
    init(id: UUID = UUID(),
         name: String,
         category: Category,
         proportions: [Proportion<T>],
         days: [Int] = [],
         portions: [Int] = []) {
        self.id = id
        self.name = name
        self.category = category
        self.proportions = proportions
        
        self.days = days
        self.portions = portions
        
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(proportions)
        hasher.combine(days)
        hasher.combine(	portions)
    }
    
    func copy(
        id: UUID? = UUID(),
        name: String? = nil,
        category: Category? = nil ,
        proportions: [Proportion<T>] = [],
        days: [Int]? = nil,
        portions: [Int]? = nil,
        automatic: Bool? = nil
    ) -> Need {
        let of = self
        return Need(
            id: id ?? of.id,
            name: name ?? of.name,
            category: category ?? of.category,
            proportions: proportions,
            days: days ?? of.days,
            portions: portions ?? of.portions
        )
        
    }
    
    static func == (lhs: Need, rhs: Need) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.category == rhs.category &&
        lhs.proportions == rhs.proportions &&
        lhs.days == rhs.days &&
        lhs.portions == rhs.portions
    }
    
}

class DefaultNeeds {
    
    fileprivate static func perKiloGram(_ divident: Measurement<Dimension>, basedOn: ProportionBasedOn = .weight, when: ProportionWhen = .unconditional) -> Proportion<Dimension> {
        let a: Measurement<Dimension> = Measurement(value: 1, unit: UnitMass.kilograms)
        return Proportion(divident: divident, divisor: a, basedOn: basedOn, when: when)
    }
    
    fileprivate static func percentageMassUnit(_ percentage: Double, basedOn: ProportionBasedOn = .category, when: ProportionWhen = .unconditional) -> Proportion<Dimension> {
        return perKiloGram(Measurement(value: 1000 * percentage, unit: UnitMass.grams), basedOn: basedOn, when: when)
    }
    
    
    let scallop = Need(name: "scallop", category: Category.animal, proportions: [ percentageMassUnit(0.5) ])
    let rumen = Need(name: "rumen", category: Category.animal, proportions: [ percentageMassUnit(0.2) ])
    let bones = Need(name: "raw meaty bones", category: Category.animal, proportions: [ percentageMassUnit(0.15) ])
    // generic insides
    let insides = Need(name: "insides", category: Category.animal, proportions: [ percentageMassUnit(0.15) ])
    // specific insides, when one is unavailable then it needs to be adjusted
    let liver = Need(name: "liver", category: Category.animal, proportions: [ percentageMassUnit(0.15 * 0.4) ])
    let lung = Need(name: "lung", category: Category.animal, proportions: [ percentageMassUnit(0.15 * 0.15) ])
    let heart = Need(name: "heart", category: Category.animal, proportions: [ percentageMassUnit(0.15 * 0.15) ])
    let kidney = Need(name: "kidney", category: Category.animal, proportions: [ percentageMassUnit(0.15 * 0.15) ])
    let spleen = Need(name: "spleen", category: Category.animal, proportions: [ percentageMassUnit(0.15 * 0.15) ])
    
    let vegetables = Need(name: "vegetables", category: Category.herbal, proportions: [ percentageMassUnit(0.8)])
    let fruits = Need(name: "fruits", category: Category.herbal, proportions: [ percentageMassUnit(0.2)])
    
    let jod = Need(name: "jod", category: Category.supplement, proportions: [
        perKiloGram(Measurement(value: 29, unit: UnitMass.micrograms), when: .youngerThan(months: 4)),
        perKiloGram(Measurement(value: 29 * 0.9, unit: UnitMass.micrograms), when: .youngerThan(months: 7)),
        perKiloGram(Measurement(value: 29 * 0.8, unit: UnitMass.micrograms), when: .youngerThan(months: 10)),
        perKiloGram(Measurement(value: 29 * 0.7, unit: UnitMass.micrograms), when: .youngerThan(months: 12)),
        perKiloGram(Measurement(value: 29 * 0.6, unit: UnitMass.micrograms), when: .youngerThan(months: 14)),
        perKiloGram(Measurement(value: 29 * 0.5, unit: UnitMass.micrograms), when: .youngerThan(months: 16)),
        perKiloGram(Measurement(value: 12.7, unit: UnitMass.micrograms), when: .unconditional),
        
    ], days: [1, 3, 5], portions: [0])
    
    let codliverOil = Need(name: "cod liver oil", category: .supplement, proportions: [
        Proportion<Dimension>(divident: Measurement(value: 0.5, unit: UnitVolume.milliliters), divisor: Measurement(value: 20, unit: UnitMass.kilograms), basedOn: .weight)
    ], days: [2, 4, 6], portions: [0])
    
    let omega3Oil = Need(name: "omega 3 oil", category: .supplement, proportions: [
        Proportion<Dimension>(divident: Measurement(value: 0.2, unit: UnitVolume.milliliters), divisor: Measurement(value: 10, unit: UnitMass.kilograms), basedOn: .weight)
    ], portions: [1]
    )
    
    
    
    
}
