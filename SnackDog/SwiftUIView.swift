//
//  SwiftUIView.swift
//  simpledogbarf
//
//  Created by Philipp on 22.12.21.
//

import SwiftUI

struct SwiftUIView: View {
    @State var test = 1
    
    var body: some View {
        TabView(selection: $test) {
            Text("The First Tab")
                .badge(10)
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("First")
                }.tag(0)
            Text("Another Tab")
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }.tag(1)
            Text("The Last Tab")
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }.tag(2)
        }
        .font(.headline)
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
