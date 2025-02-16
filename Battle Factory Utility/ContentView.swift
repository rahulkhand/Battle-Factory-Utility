//
//  ContentView.swift
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/11/25.
//

import SwiftUI
import Foundation

typealias json = nlohmann.json

let pokemon_filepath = Bundle.main.path(forResource: "battle_factory_pokemon.json", ofType: nil) ?? ""
let factorySearcher = FactorySearcher()
let numMoves = 4

enum DisplayPage {
    case SearchPage
    case ResultsPage
    case EntryDetailPage
}

struct ContentView: View {
    @State private var pageState : DisplayPage = DisplayPage.SearchPage
    @State private var queryName = ""
    @State private var queryItem = ""
    @State private var queryMoves = [String](repeating: "", count: numMoves)
    @State private var pkmnSets = FactorySearcher.factorySets()
    @State private var selectedEntryIndex : Int?
    
    var body: some View
    {
        ZStack {
            Image("Wallpaper")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            VStack{
                if (pageState == DisplayPage.SearchPage)
                {
                    SearchView(pkmnSets: $pkmnSets, queryName: $queryName, queryItem: $queryItem, queryMoves: $queryMoves, pageState: $pageState)
                }
                else if (pageState == DisplayPage.ResultsPage)
                {
                    ResultsView(pkmnResults: $pkmnSets, pageState: $pageState, clickedIndex: $selectedEntryIndex)
                }
                else if (pageState == DisplayPage.EntryDetailPage)
                {
                    EntryDetailView(pokemonRecord: pkmnSets[selectedEntryIndex!], pageState: $pageState)
                }
            }
        }
    }
}

struct EntryDetailView: View {
    var pokemonRecord : json
    @Binding var pageState : DisplayPage
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack{
                
                let resultName = String(FactorySearcher.getString(pokemonRecord["name"]))
                let resultItem = String(FactorySearcher.getString(pokemonRecord["item"]))
                let resultMoves = FactorySearcher.getStrings(pokemonRecord["moves"])
                let resultNature = String(FactorySearcher.getString(pokemonRecord["nature"]))
                let statClasses = ["hp", "attack", "defense", "spAttack", "spDefense", "speed"]
                let formattedStatClasses = ["HP", "Attack", "Defense", "Special Attack", "Special Defense", "Speed"]
                
                
                Text("\(resultName) @ \(resultItem)").font(.caption).dynamicTypeSize(.accessibility2).padding([.top], 10).foregroundStyle(.white)
                Text("\(resultNature) Nature").font(.caption).dynamicTypeSize(.accessibility1).padding([.bottom], 10).foregroundStyle(.white)

                List {
                    Section
                    {
                        ForEach(0..<numMoves, id: \.self) { index in
                            HStack {
                                let resultMove = String(resultMoves[index])
                                Text("- \(resultMove)").opacity(0.95)
                            }
                           .contentShape(Rectangle())
                        }
                    }
                    Section {
                        ForEach(0..<statClasses.count, id: \.self) { index in
                            HStack {
                                let statValue = FactorySearcher.getInt(pokemonRecord["evs"][std.string(statClasses[index])])
                                Text("\(formattedStatClasses[index]): \(statValue)")
                                Spacer()
                            }
                           .contentShape(Rectangle())
                        }
                    }
                }.scrollContentBackground(.hidden).opacity(0.9).scrollDisabled(true)
                
                HStack {
                    
                    Button {
                        pageState = DisplayPage.ResultsPage
                    } label : {
                        Text("Back to Results").frame(width: 180.0, height: 100).tint(.white)
                    }.cornerRadius(6.0)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.purple))
                        .padding([.trailing, .leading], 5).opacity(1.0)
                    
                    Button {
                        pageState = DisplayPage.SearchPage
                    } label : {
                        Text("Back to Search").frame(width: 180.0, height: 100)
                    }.cornerRadius(6.0)
                        .background(RoundedRectangle(cornerRadius: 6).fill(.orange)).tint(.white)
                        .padding([.trailing, .leading], 5).opacity(1.0)
                    
                }
            }
        }
    }
}

struct ResultsView: View {
    @State private var showRecords : Bool = true
    @Binding var pkmnResults : FactorySearcher.factorySets
    @Binding var pageState : DisplayPage
    @Binding var clickedIndex : Int?
    var body: some View {
        let numRecords = pkmnResults.size()
        
        VStack {
            List {
                ForEach(0..<numRecords, id: \.self) { index in
                    HStack {
                        let resultPokeName = FactorySearcher.getString(pkmnResults[index]["name"])
                        let resultPokeItem = FactorySearcher.getString(pkmnResults[index]["item"])
                       Text("\(resultPokeName) @ \(resultPokeItem)")
                       Spacer()
                    }
                   .contentShape(Rectangle())
                   .onTapGesture {
                       clickedIndex = index
                       pageState = DisplayPage.EntryDetailPage
                    }
                }
            }.padding()
                .scrollContentBackground(.hidden).opacity(0.9)
            ZStack(alignment: .bottom)
            {
                Button {
                    pageState = DisplayPage.SearchPage
                } label : {
                    Text("Back to Search").frame(width: 200.0, height: 100)
                }.cornerRadius(6.0)
                    .background(RoundedRectangle(cornerRadius: 6).fill(.orange)).tint(.white)
                    .padding()
            }
        }
        
    }
}

struct SearchView: View {
    @Binding var pkmnSets : FactorySearcher.factorySets
    @Binding var queryName : String
    @Binding var queryItem : String
    @Binding var queryMoves : [String]
    @Binding var pageState : DisplayPage
    
    var body: some View {
        VStack
        {
            HStack
            {
                VStack
                {
                    Text("Pokémon Name").padding()
                    Text("Pokémon Item").padding()
                }
                VStack
                {
                    TextField("Enter name ", text: $queryName).padding().autocorrectionDisabled()
                    TextField("Enter item ", text: $queryItem).padding().autocorrectionDisabled()
                }
            }.padding([.leading], 10).background(.white).opacity(0.9)
            VStack
            {
                Text("Pokémon Moves")
                HStack
                {
                    TextField("Move 1", text: $queryMoves[0]).padding().border(.blue).autocorrectionDisabled()
                    TextField("Move 2", text: $queryMoves[1]).padding().border(.blue).autocorrectionDisabled()
                }.opacity(0.8)
                HStack
                {
                    TextField("Move 3", text: $queryMoves[2]).padding().border(.blue).autocorrectionDisabled()
                    TextField("Move 4", text: $queryMoves[3]).padding().border(.blue).autocorrectionDisabled()
                }
            }.padding().background(.white).opacity(0.9)
            
            Button {
                var cppMovesQuery : FactorySearcher.entryList = ["", "", "", ""]
                for i in (0...(numMoves - 1))
                {
                    cppMovesQuery[i] = std.string(queryMoves[i])
                }
                pkmnSets = factorySearcher.getPossibleSets(std.string(queryName), cppMovesQuery, std.string(queryItem), false, std.string(pokemon_filepath))
                pageState = DisplayPage.ResultsPage
            } label : {
                Text("Search").frame(width: 200.0, height: 100)
            }.cornerRadius(6.0)
                .background(RoundedRectangle(cornerRadius: 6).fill(.green)).tint(.white)
                .padding([.top], (30))
        }

    }
}

#Preview {
    ContentView()
}
