import SwiftUI
import CoreData
struct DetailsDeleteSwipeable: ViewModifier {
    
    let onDelete: () -> Void
    let onDetails: () -> Void
    
    func body(content: Content) -> some View {
        content.swipeActions{
            Button(role: .destructive, action: onDelete){
                Label("Delete", systemImage: "trash")
            }.keyboardShortcut("d")
            Button(action: onDetails) {
                Label("Details", systemImage: "rectangle.and.pencil.and.ellipsis")
            }.keyboardShortcut("e")
                .tint(Color(UIColor.systemGray))
        }
    }
}

struct DetailsDialog: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    
    var onCancel: (() -> Void)?
    var onCommit: () -> Void
    
    private func doCancel() {
        onCancel?()
        dismiss()
    }
    
    private func doCommit() {
        onCommit()
        dismiss()
    }
    
    func body(content: Content) -> some View {
        
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        doCancel()
                    } label: {
                        Label("Cancel", systemImage: "x.square").labelStyle(.titleAndIcon)
                    }.keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    
                    Button(action: doCommit) {
                        Label("Done", systemImage: "checkmark.square").labelStyle(.titleAndIcon)
                    }.keyboardShortcut(.defaultAction)
                }
                
            }
        
        
    }
}

extension View {
    
    
    
    func detailsDeleteSwipeable(onDetails: @escaping ()->Void, onDelete: @escaping ()->Void) -> some View {
        self.modifier(DetailsDeleteSwipeable(onDelete: onDelete, onDetails: onDetails))
    }
    
    func detailsDialog(onCancel: (() -> Void)? = nil, onCommit: @escaping () -> Void) -> some View {
        NavigationView {
            self.modifier(DetailsDialog(onCancel: onCancel, onCommit: onCommit))
        }
    }
    func detailsView(onCancel: (() -> Void)? = nil, onCommit: @escaping () -> Void) -> some View {
        self.modifier(DetailsDialog(onCancel: onCancel, onCommit: onCommit))
    }
    
}
