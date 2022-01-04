//
//  Data.swift
//  SnackDog
//
//  Created by Philipp on 06.01.22.
//

import Foundation

struct AlgaePowder: Identifiable, Hashable {
    var id: UUID
    var name: String
    
    var jod: Measurement<UnitMass>
    var per: Measurement<UnitMass>
    
    static func from(jodData: JodData?) -> AlgaePowder {
        return AlgaePowder(
            id: jodData?.id ?? UUID(),
            name: jodData?.name ?? "Default",
            jod: jodData?.value?.measurement() ?? Measurement(value: 631, unit: .milligrams),
            per: jodData?.per?.measurement() ?? Measurement(value: 1, unit: .kilograms)
        )
    }
}

struct EDog: Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var weight: Measurement<UnitMass>
    var activityHours: Int16
    var size: DogSize
    var isNautered: Bool
    var isOld: Bool
    
    static func == (a: EDog, b: EDog) -> Bool {
        return a.id == b.id &&
        a.name == b.name &&
        a.birthDate == b.birthDate  &&
        a.weight == b.weight &&
        a.activityHours == b.activityHours &&
        a.size == b.size &&
        a.isNautered == b.isNautered &&
        a.isOld == b.isOld
    }
    
    static func new() -> EDog {
        return EDog(
            id: UUID(),
            name: "",
            birthDate: Date(),
            weight: Measurement<UnitMass>(value: 0, unit: .kilograms),
            activityHours: 2,
            size: .medium,
            isNautered: false,
            isOld: false)
    }
}
