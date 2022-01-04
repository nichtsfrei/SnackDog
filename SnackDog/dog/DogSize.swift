import Foundation

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
        for t in factor {
            if let compontent = t.0 {
                let age = calendar.dateComponents([compontent], from: birthDate, to: Date()).value(for: compontent)!
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
