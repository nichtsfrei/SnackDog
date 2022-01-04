//
//  EmptyView.swift
//  SnackDog
//
//  Created by Philipp on 03.01.22.
//

import SwiftUI

struct EmptyStateViewModifier<T>: ViewModifier where T: View {
    var isEmpty: Bool
    let emptyContent: () -> T
    
    func body(content: Content) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            content
        }
    }
}

extension View {
    func emptyState<T>(_ isEmpty: Bool,
                       emptyContent: @escaping () -> T) -> some View where T: View {
        modifier(EmptyStateViewModifier(isEmpty: isEmpty, emptyContent: emptyContent))
    }
}
