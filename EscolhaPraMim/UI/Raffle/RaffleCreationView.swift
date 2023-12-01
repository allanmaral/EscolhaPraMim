//
//  RaffleCreationView.swift
//  EscolhaPraMim
//
//  Created by Allan Amaral on 22/11/23.
//

import SwiftData
import SwiftUI

struct RaffleCreationView: View {
    @Environment(\.dismiss) private var onDismiss
    @State private var title: String = ""
    
    var onCreate: (_ title: String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $title)
                    .submitLabel(.done)
                    .onSubmit(create)
            }
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", action: dismiss)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar", action: create)
                        .disabled(title.isEmpty)
                }
            })
            .navigationTitle("Novo sorteio")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.fraction(0.2)])
    }
    
    func create() {
        guard !title.isEmpty else { return }
        onCreate(title)
    }
    
    func dismiss() {
        onDismiss()
    }
}

#Preview {
    Text("Sample")
        .sheet(isPresented: .constant(true)) {
            RaffleCreationView() { _ in }
        }
}
