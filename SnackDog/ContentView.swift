import SwiftUI



struct Sidebar: View {
    
    var body: some View {
        return List {
            NavigationLink(
                destination: DogsView()
            ) {
                Text("Dogs")
            }
            NavigationLink(destination: BasePlanOverView()) {
                Text("Plan")
            }
            NavigationLink(
                destination: AlgaePowderView( )
            ) {
                Text("Algae Powder")
            }
            
        }.listStyle(SidebarListStyle())
    }
}

struct ContentView: View {
    
    @EnvironmentObject private var dogs: Fetcher<Dog>
    @EnvironmentObject private var jod: Fetcher<JodData>
    
   
    
    var body: some View {
        
        return NavigationView {
            Sidebar()
            DogsView()
            ProgramStartView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, vc)
            .previewDevice("iPhone 13 mini")
    }
}
