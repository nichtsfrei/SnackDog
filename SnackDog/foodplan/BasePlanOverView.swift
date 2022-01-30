import SwiftUI

struct BasePlanDestinationView: View {
    let plan: FoodBasePlan
    var body: some View {
        NavigationLink(LocalizedStringKey(plan.name)) {
            BasePlanView(plan: plan)
        }
        
    }
}

struct BasePlanOverView: View {
    @State var basePlan: [FoodBasePlan] = FoodBasePlan.predefined
    
    var body: some View {
        List {
            ForEach(basePlan) {
                BasePlanDestinationView(plan: $0)
            }
        }
        .navigationTitle("Plan")
            
    }
}

struct FoodBasePlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BasePlanOverView()
        }
    }
}
