import Foundation

extension String {
    private static let all: [String: UnitMass] =  [
        "kg": .kilograms,
        "g": .grams,
        "mg": .milligrams,
        "µg": .micrograms,
        "ng": .nanograms,
        "lb": .pounds,
        "oz": .ounces,
        "st": .stones,
        "oz t": .ouncesTroy,
    ]
    
    static let supportedMassUnits: [String: UnitMass] =
    Locale.current.usesMetricSystem ? [
        "kg": .kilograms,
        "g": .grams,
        "mg": .milligrams,
        "µg": .micrograms,
        "ng": .nanograms,
    ] : [
        "lb": .pounds,
        "oz": .ounces,
        "st": .stones,
        "oz t": .ouncesTroy,
    ]
    func toUnitMass() -> UnitMass? {
        return String.all[self]
        
    }
}

extension MeasurementData {
    func measurement() -> Measurement<UnitMass>? {
        if let unit = self.symbol?.toUnitMass() {
            return Measurement(value: self.value, unit: unit)
        }
        return nil
        
    }
}

extension Dog {
    func toEdog() -> EDog {
        let dog = self
        
        return EDog(
            id: self.id ?? UUID(),
            name: dog.name ?? "",
            birthDate: dog.birthdate ?? Date(),
            
            weight: dog.weight?.measurement() ?? Measurement(value: 0, unit: .kilograms) ,
            
            activityHours: dog.activity_hours,
            size: DogSize(rawValue: dog.typus ?? "small") ?? .small,
            isNautered: dog.is_nautered,
            isOld: dog.is_old
        )
    }
}
