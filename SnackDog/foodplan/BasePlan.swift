import Foundation

class FoodBasePlan: Hashable, Identifiable {
    
    let id: UUID
    let name: String
    let needs: [Need<Dimension>]
    
    init(id: UUID = UUID(), name: String, needs: [Need<Dimension>]) {
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
    static let defaultNeeds = DefaultNeeds()
    static let summarizedInsides: FoodBasePlan = FoodBasePlan(name: "pooled insides", needs: [
        defaultNeeds.scallop,
        defaultNeeds.rumen,
        defaultNeeds.insides,
        defaultNeeds.bones,
        defaultNeeds.vegetables,
        defaultNeeds.fruits,
        defaultNeeds.jod,
        defaultNeeds.codliverOil,
        defaultNeeds.omega3Oil,
    ]
    )
    
//    static func justSoftBones(basedOn: FoodBasePlan) -> FoodBasePlan {
//
//        let needs: [Need<Unit>] = basedOn.needs.map {
//
//            if $0 == defaultNeeds.rumen {
//                return $0.copy(percentage:0.15)
//            }
//            if $0 == Need.bones {
//                return $0.copy(percentage: 0.20)
//            }
//            return $0
//        }
//        return FoodBasePlan(name: "\(basedOn.name) soft bones", needs: needs)
//    }
//    static let summarizedInsidesOnlyWeakBones: FoodBasePlan = justSoftBones(basedOn: FoodBasePlan.summarizedInsides)
    
    static let separatedInsides: FoodBasePlan = FoodBasePlan(name: "insides", needs: [
        defaultNeeds.scallop,
        defaultNeeds.rumen,
        defaultNeeds.liver,
        defaultNeeds.lung,
        defaultNeeds.heart,
        defaultNeeds.kidney,
        defaultNeeds.spleen,
        defaultNeeds.bones,
        defaultNeeds.vegetables,
        defaultNeeds.fruits,
        defaultNeeds.jod,
        defaultNeeds.codliverOil,
        defaultNeeds.omega3Oil,
    ])
//    static let separatedInsidesOnlyWeakBones: FoodBasePlan = justSoftBones(basedOn: FoodBasePlan.separatedInsides)
    
    static let predefined: [FoodBasePlan] = [
        .summarizedInsides,
//        .summarizedInsidesOnlyWeakBones,
        .separatedInsides,
//        .separatedInsidesOnlyWeakBones
    ]
}
