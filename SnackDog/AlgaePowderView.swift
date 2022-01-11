import SwiftUI

fileprivate extension Fetcher {
    
 
    func getOrCreate(_ jd: JodData?) -> JodData {
        if let result = jd {
            return result
        }
        return self.withConext {
            let result = JodData(context: $0)
            return result
        }
    }
    
    func save(_ changedData: AlgaePowder, _ basedOn: JodData?) {
        let jodData = getOrCreate(basedOn)
        jodData.id = changedData.id
        jodData.name = changedData.name
        jodData.value = measurementData(md: basedOn?.value)
        jodData.value?.value = changedData.jod.value
        jodData.value?.symbol = changedData.jod.unit.symbol
        jodData.per = measurementData(md: basedOn?.per)
        jodData.per?.value = changedData.per.value
        jodData.per?.symbol = changedData.per.unit.symbol
        
        self.save()
        self.selected = nil
        self.updated.toggle()
    }
}


struct AlgaePowderView: View {
    
    struct SingleView: View {
        @EnvironmentObject var fetcher: Fetcher<JodData>
        let data: JodData
        
        @Binding var updated: Bool
        
        var body: some View {
            let jm = data.value?.measurement() ?? Measurement(value: 0, unit: .milligrams)
            let jp = data.per?.measurement() ?? Measurement(value: 0, unit: .kilograms)
            return VStack {
                HStack {
                    NavigationLink(destination: EditView(jod: data) { changedData in
                        fetcher.save(changedData, data)
                    }){
                        Text(data.name ?? "").font(.title2)
                    }
                    Spacer()
                }
                HStack {
                    Text(jm.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
                    Text("/").foregroundColor(.secondary)
                    Text(jp.formatted(.measurement(width: .abbreviated))).foregroundColor(.secondary)
                    Spacer()
                }
            }
            
            
        }
    }
    
    @EnvironmentObject var fetcher: Fetcher<JodData>
    
    var body: some View {
        return List{
            ForEach(fetcher.data) { jod in
                SingleView(data: jod, updated: $fetcher.updated)
                    .detailsDeleteSwipeable(
                        onDetails: { fetcher.selected = jod },
                        onDelete: { fetcher.delete(jod)}
                    )
            }
        }
        .emptyState($fetcher.data.isEmpty) {
            Text("No Algae Powder")
                .font(.title3)
                .foregroundColor(Color.secondary)
        }
        .sheet(item: $fetcher.selected) { data in
            EditDialog(jod: data){ changedData in
                fetcher.save(changedData, data)
            }
        }
        .listStyle(.plain)
        .toolbar{
            NavigationLink(
                destination:
                    EditView(jod: nil) { changedData in
                        fetcher.save(changedData, nil)
                    }.navigationTitle("New")) {
                        Image(systemName: "plus.app")
                    }.keyboardShortcut(.defaultAction)
            
        }
        .navigationTitle("Algae Powder")
    }
    
}

struct JodView_Previews: PreviewProvider {
    static var previews: some View {
        let vc = PersistenceController.preview.container.viewContext
        NavigationView {
            AlgaePowderView()
                .environmentObject(Fetcher(context: vc, basefetchRequest: JodData.fetchRequest()))
        }
    }
}
