//
//  Reload.swift
//  simpledogbarf
//
//  Created by Philipp on 21.12.21.
//

import Foundation
import SwiftUI

enum ViewState: Int {
    case overview = 0, add, edit, delete, foodplan
}

enum KindState: Int {
    case dogs = 0, algae
}


class Shared: ObservableObject {
    
    @Published var kindState: KindState? = .dogs
    @Published var viewstate: ViewState? = .overview
    @Published var selected: Dog? = nil
    @ObservedObject var dogFetcher: Fetcher<Dog>
    var dogManipulator: DogManipulator
    
    init(fetcher: Fetcher<Dog>, manipulator: DogManipulator) {
        self.dogFetcher = fetcher
        self.dogManipulator = manipulator
        if fetcher.data.count > 0 {
            self.selected = fetcher.data[0]
        }
        if fetcher.data.count == 1 {
            self.viewstate = .foodplan
        }
        if fetcher.data.count == 0 {
            self.viewstate = .add
        }
    }
    
    
    
    
}
