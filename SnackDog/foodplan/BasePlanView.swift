import SwiftUI

struct NeedListView: View {
    let need: Need<Dimension>
    let weekdays = Locale.current.calendar.weekdaySymbols
    
    private func caluldateDivident(_ p: Proportion<Dimension>) -> Measurement<Dimension>{
        var divident = p.divident
        
        if p.basedOn == .category {
            divident.value = divident.value * need.category.percentage()
        }
        return divident
    }
    
    var body: some View {
        let days = HStack {
            if (need.days == []) {
                Text(LocalizedStringKey("Daily")).font(.footnote).foregroundColor(.secondary)
            } else {
                
                ForEach(need.days, id: \.self) {
                    Text(weekdays[$0]).font(.footnote).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        let portions = HStack {
            if (need.portions == []) {
                Text(LocalizedStringKey("per portion")).font(.footnote).foregroundColor(.secondary)
            } else {
                ForEach(need.portions, id: \.self) {
                    Text("\($0 + 1). portion").font(.footnote).foregroundColor(.secondary)
                }
            }
            
        }
        let label = HStack {
            Text(LocalizedStringKey(need.name))
            Spacer()
            portions
        }
        GroupBox(label: label) {
            days
            ForEach(need.proportions, id: \.self) { p in
                
                HStack {
                    Text(caluldateDivident(p).formatted(.measurement(width: .abbreviated)))
                    Text("/").foregroundColor(.secondary)
                    Text(p.divisor.formatted(.measurement(width: .abbreviated)))
                    Spacer()
                }
                if p.when != .unconditional {
                    HStack {
                        switch p.when {
                            
                        case .unconditional:
                            // Nothing
                            EmptyView()
                        case .youngerThan(let months):
                            Text("when younger than \(months) months").font(.footnote).foregroundColor(.secondary)
                        case .olderThan(let months):
                            Text("when older than \(months) months")
                        }
                        Spacer()
                    }
                }
            }
            
        }
        
    }
}

struct OverView: View {
    let category: Category
    let needs: [Need<Dimension>]
    
    var body: some View {
        let label  = HStack {
            Text(category.symbol) + Text(LocalizedStringKey(category.name))
            Spacer()
            if category.divisor.value > 0 {
                HStack {
                    Text(category.divisor.formatted(.measurement(width: .abbreviated)))
                    Text("/").foregroundColor(.secondary)
                    Text(category.divident.formatted(.measurement(width: .abbreviated)))
                }
               
            }
        }
        GroupBox(label: label) {
            VStack(alignment: .leading, spacing: 1.0) {
                ForEach(needs) {
                    NeedListView(need: $0)
                }
            }
        }
    }
}

struct BasePlanView: View {
    let plan: FoodBasePlan
    
    var body: some View {
        let gCategories = Dictionary(grouping: plan.needs) {
            $0.category
        }.map { c in
            OverView(category: c.key, needs: c.value)
        }.sorted{ a, b in
            a.category.sortIndex < b.category.sortIndex
        }
        
        return List{
                ForEach(gCategories, id: \.category.id) {
                    $0
                }
        }.navigationTitle(LocalizedStringKey(plan.name))
        }
}

struct BasePlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        BasePlanView(plan: FoodBasePlan.predefined[0])
        }
    }
}
