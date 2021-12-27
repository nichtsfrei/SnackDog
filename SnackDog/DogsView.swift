//
//  DogsView.swift
//  SnackDog
//
//  Created by Philipp on 24.12.21.
//

import SwiftUI

struct SingleDogView: View {
    @State var dog: Dog
    @StateObject var shared: Shared
    
    var body: some View {
        let formatter = DateFormatter()
        let name = dog.name ?? "Unknown"
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return GroupBox(label: HStack {
            Text(name)
            if let weight = dog.weight?.measurement() {
                Text(weight.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
            }
        }) {
            HStack {
                Image(systemName: "calendar.circle")
                Text(formatter.string(from: dog.birthdate ?? Date()))
                Spacer()
                
                Button(action: {
                    let _ = shared.dogManipulator.remove(t: dog)
                    shared.viewstate = .overview
                }) {
                    Image(systemName: "trash")
                }
                Button(action: {
                    shared.selected = dog
                    shared.viewstate = .edit
                }){
                    Image(systemName: "square.and.pencil")
                }
            }
        }.onTapGesture {
            shared.selected = dog
            shared.viewstate = .foodplan
        }.onLongPressGesture{
            shared.selected = dog
            shared.viewstate = .edit
        }
        
    }
}

struct DogsView: View {
    
    @StateObject var shared: Shared
    let jodFetcher: Fetcher<JodData>
    
    init(shared: Shared) {
        self._shared = StateObject(wrappedValue: shared)
        self.jodFetcher = Fetcher(
            managedObjectContext: shared.dogManipulator.viewContext,
            basefetchRequest: JodData.fetchRequest()
        )
    }
    
    var body: some View {
        List {
            ForEach(shared.dogFetcher.data) { dog in
                SingleDogView(dog: dog, shared: shared)
            }
        }
        .navigationTitle("Dogs")
        .toolbar{
            HStack {
                let dog = shared.selected?.toEdog() ?? EDog.new()
                
                NavigationLink(
                    destination: FoodPlanView(dog: dog, jodData:jodFetcher.data),
                    tag: .foodplan,
                    selection: $shared.viewstate
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: DogEditView(refresh: shared, dog: EDog.new()).navigationTitle("Add"),
                    tag: .add,
                    selection: $shared.viewstate
                ) {
                    Image(systemName: "plus.app")
                }
                NavigationLink(
                    destination: DogEditView(refresh: shared, dog: dog).navigationTitle("Edit"),
                    tag: .edit,
                    selection: $shared.viewstate
                ) {
                    EmptyView()
                }
                
            }
        }
    }
}

struct DogsView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        let shared = Shared(
            fetcher: Fetcher<Dog>(managedObjectContext: vc, basefetchRequest: Dog.fetchRequest()),
            manipulator: DogManipulator(context: vc)
        )
        NavigationView {
            DogsView(shared: shared)
        }
    }
}
