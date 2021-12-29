import SwiftUI

enum ViewState: Int {
    case overview = 0, add, edit, delete, foodplan
}

struct SingleDogView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var dog: Dog
    @Binding var selected: Dog?
    @Binding var viewState: ViewState?
    
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
                    viewContext.delete(dog)
                    do {
                        try viewContext.save()
                    } catch {
                        print("ignoring error while saving: \(error)")
                    }
                }) {
                    Image(systemName: "trash")
                }
                
                Button(action: {
                    selected = dog
                    viewState = .edit
                }){
                    Image(systemName: "square.and.pencil")
                }
            }
        }.onTapGesture {
            selected = dog
            viewState = .foodplan
        }.onLongPressGesture{
            selected = dog
            viewState = .edit
        }
        
    }
}

struct DogsView: View {
    
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dog.name, ascending: true)],
        animation: .default)
    private var dogs: FetchedResults<Dog>
    
    
    
    @State var selected: Dog?
    @State var viewstate: ViewState? = .overview
    
    var body: some View {
        List {
            ForEach(dogs) { dog in
                SingleDogView(dog: dog, selected: $selected, viewState: $viewstate)
            }
        }
        .navigationTitle("Dogs")
        .toolbar{
            HStack {
                let dog = selected?.toEdog() ?? EDog.new()
                
                NavigationLink(
                    destination: FoodPlanView(dog: dog),
                    tag: .foodplan,
                    selection: $viewstate
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: DogEditView(selected: $selected, viewState: $viewstate)
                        .navigationTitle("Add"),
                    tag: .add,
                    selection: $viewstate
                ) {
                    Image(systemName: "plus.app")
                }
                NavigationLink(
                    destination: DogEditView(selected: $selected, viewState: $viewstate)
                        .navigationTitle("Edit"),
                    tag: .edit,
                    selection: $viewstate
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
        NavigationView {
            DogsView().environment(\.managedObjectContext, vc)
        }
    }
}
