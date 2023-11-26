//
//  RaffleEditingView.swift
//  EscolhaPraMim
//
//  Created by Allan Amaral on 22/11/23.
//

import SwiftData
import SwiftUI

struct RaffleEditingView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var raffle: Raffle
    
    @State private var newOptionContent = ""
    @FocusState private var isNewOptionFocused
    
    var body: some View {
        ZStack {
            Color.formBackground.ignoresSafeArea()
            ScrollView {
                newOptionInput.padding()
                optionsGrid.padding()
            }
        }
        .onTapGesture(perform: endEditing)
        .overlay(alignment: .bottom, content: { chooseForMeButton })
        .navigationTitle(raffle.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Shuffle", systemImage: "shuffle", action: shuffle)
        }
    }
    
    var newOptionInput: some View {
        HStack {
            TextField("Nova opção", text: $newOptionContent)
                .submitLabel(.done)
                .focused($isNewOptionFocused)
                .onSubmit(addOption)
            
            Button("Adicionar", action: addOption)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.inputBackground))
    }
    
    var optionsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], content: {
            ForEach(raffle.options.sorted(by: { $0.order < $1.order })) { option in
                CardView(card: Card(content: option.content, flipped: option.flipped))
                    .aspectRatio(5/6, contentMode: .fit)
                    .onTapGesture { flip(option) }
            }
        })
        .foregroundStyle(Gradient.backgroundCard)
    }
    
    @ViewBuilder
    var chooseForMeButton: some View {
        if raffle.options.count >= 2 {
            Button("Escolha para mim!", action: raffleOption)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(8)
                .padding()
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    func endEditing() {
        isNewOptionFocused = false
    }
    
    func flip(_ option: Option) {
        endEditing()
        withAnimation {
            option.flipped.toggle()
        }
    }
    
    func addOption() {
        guard newOptionContent.isEmpty == false else { return }
        
        withAnimation {
            let option = Option(content: newOptionContent, order: raffle.options.count)
            raffle.options.append(option)
            newOptionContent = ""
        }
    }
    
    func shuffle() {
        withAnimation {
            var order = 0
            for optionIndex in raffle.options.indices.shuffled() {
                raffle.options[optionIndex].order = order
                raffle.options[optionIndex].flipped = true
                order += 1
            }
        }
    }
    
    func raffleOption() {
        var delay: TimeInterval = 0
        for _ in 0..<5 {
            withAnimation(.linear(duration: 0.3).delay(delay)) {
                var order = 0
                for optionIndex in raffle.options.indices.shuffled() {
                    raffle.options[optionIndex].flipped = true
                    raffle.options[optionIndex].order = order
                    order += 1
                }
            }
            delay += 0.25
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(1500))) {
            withAnimation {
                let chosenIndex = raffle.options.indices.randomElement()
                if let chosenIndex {
                    raffle.options[chosenIndex].flipped = false
                }
            }
        }
    }
}

#Preview {
    do {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Raffle.self, configurations: configuration)
        let modelContext = ModelContext(container)
        let raffle = Raffle(
            "O que assistir?",
            options: [
                Option(content: "Jurassic Park", order: 1),
                Option(content: "Star Wars", flipped: true, order: 2),
                Option(content: "Blade Runner", flipped: true, order: 3),
                Option(content: "Terminator", order: 4)
            ]
        )
        modelContext.insert(raffle)
        return RaffleEditingView(raffle: raffle)
    } catch {
        fatalError("Failed to create model container.")
    }
}
