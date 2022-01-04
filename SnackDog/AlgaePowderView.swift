import SwiftUI

fileprivate extension Fetcher {
    
    func measurementData(md: MeasurementData?) -> MeasurementData {
        return self.withConext{ context in
            let result = MeasurementData(context: context)
            result.id = md?.id ?? UUID()
            return result
        }
        
    }
    
    func save(_ changedData: AlgaePowder, _ basedOn: JodData?) -> JodData {
        let result: JodData = self.withConext{ context in
            let jodData = JodData(context: context)
            jodData.id = changedData.id
            jodData.name = changedData.name
            jodData.value = measurementData(md: basedOn?.value)
            jodData.value?.value = changedData.jod.value
            jodData.value?.symbol = changedData.jod.unit.symbol
            jodData.per = measurementData(md: basedOn?.per)
            jodData.per?.value = changedData.per.value
            jodData.per?.symbol = changedData.per.unit.symbol
            return jodData
        }
        let _ = self.save()
        return result
    }
}


struct AlgaePowderView: View {
    
    struct SingleView: View {
        @EnvironmentObject var fetcher: Fetcher<JodData>
        let data: JodData
        
        @Binding var updated: JodData?
        
        var body: some View {
            let jm = data.value?.measurement() ?? Measurement(value: 0, unit: .milligrams)
            let jp = data.per?.measurement() ?? Measurement(value: 0, unit: .kilograms)
            return VStack {
                HStack {
                    NavigationLink(destination: EditView(jod: data) { changedData in
                        updated = fetcher.save(changedData, data)
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
    
    // will be set to trigger a refresh of the list view
    @State var updated: JodData? = nil
    // Selected for details dialog
    @State var details: JodData? = nil
    
    var body: some View {
        return List{
            ForEach(fetcher.data) { jod in
                SingleView(data: jod, updated: $updated)
                    .detailsDeleteSwipeable(
                        onDetails: { details = jod },
                        onDelete: { fetcher.delete(jod)}
                    )
            }
        }
        .emptyState($fetcher.data.isEmpty) {
            Text("No Algae Powder")
                .font(.title3)
                .foregroundColor(Color.secondary)
        }
        .sheet(item: $details) { data in
            EditDialog(jod: data){ changedData in
                updated = fetcher.save(changedData, data)
            }
        }
        .listStyle(.plain)
        .toolbar{
            NavigationLink(
                destination:
                    EditView(jod: nil) { changedData in
                        updated = fetcher.save(changedData, nil)
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
