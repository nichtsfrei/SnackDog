import Foundation

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
    
    static let summarizedInsides: FoodBasePlan = FoodBasePlan(name: "pooled insides", needs: [
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
    
    static func justSoftBones(basedOn: FoodBasePlan) -> FoodBasePlan {
        
        let needs: [Need] = basedOn.needs.map {
            
            if $0 == Need.rumen {
                return $0.copy(percentage:0.15)
            }
            if $0 == Need.bones {
                return $0.copy(percentage: 0.20)
            }
            return $0
        }
        return FoodBasePlan(name: "\(basedOn.name) soft bones", needs: needs)
    }
    static let summarizedInsidesOnlyWeakBones: FoodBasePlan = justSoftBones(basedOn: FoodBasePlan.summarizedInsides)
    
    static let separatedInsides: FoodBasePlan = FoodBasePlan(name: "insides", needs: [
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
    static let separatedInsidesOnlyWeakBones: FoodBasePlan = justSoftBones(basedOn: FoodBasePlan.separatedInsides)
}
