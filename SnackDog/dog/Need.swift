import Foundation

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
        // TODO adapt maximun to 6% when not puppy or pregnant
        return result > 0.1 ? 0.1 : result
    }
    
    
    

    
}

struct Category: Identifiable, Hashable {
    let id: Int
    let name: String
    let symbol: String
    let percentage: Double // Of food
    
    
    
    static let animal = Category(id: 0, name: "Animal", symbol: "🥩", percentage: 0.8)
    static let herbal = Category(id: 1, name: "Herbal", symbol: "🥗", percentage: 0.2)
    static let supplement = Category(id: 2, name: "Supplements", symbol: "💊", percentage: 0)
    
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
