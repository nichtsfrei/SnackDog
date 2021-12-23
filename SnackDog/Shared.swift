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



class Shared: ObservableObject {
    
    @Published var viewstate: ViewState? = .overview
    
    @Published var selected: Dog? = nil
    
    @ObservedObject var fetcher: DogFetcher
    
    var manipulator: DogManipulator
    
    init(fetcher: DogFetcher, manipulator: DogManipulator) {
        self.fetcher = fetcher
        self.manipulator = manipulator
        if fetcher.dogs.count > 0 {
            self.selected = fetcher.dogs[0]
        }
        if fetcher.dogs.count == 1 {
            self.viewstate = .foodplan
        }
        if fetcher.dogs.count == 0 {
            self.viewstate = .add
        }
    }
    
    
    
    
}
