//
//  ContentView.swift
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/11/25.
//

import SwiftUI
import Foundation

let pokemon_filepath = Bundle.main.path(forResource: "battle_factory_pokemon.json", ofType: nil) ?? ""
let factorySearcher = FactorySearcher()
let numMoves = 4
let pickMoves = FactorySearcher.entryList()

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
            EntryDetailView(pageState: $pageState)
        }
    }
}

struct EntryDetailView: View {
    @Binding var pageState : DisplayPage
    
    var body: some View {
        Button("Back to Results")
        {
            pageState = DisplayPage.ResultsPage
        }
        .frame(width: 200.0, height: 100)
        .background(.pink)
        Button("Back to Search")
        {
            pageState = DisplayPage.SearchPage
        }
        .frame(width: 200.0, height: 100)
        .background(.orange)
    }
}

struct ResultsView: View {
    @State private var showRecords : Bool = true
    @Binding var pkmnResults : FactorySearcher.factorySets
    @Binding var pageState : DisplayPage
    @Binding var clickedIndex : Int?
    var body: some View {
        let numRecords = pkmnResults.size()
        if (showRecords)
        {
            VStack {
                List {
                    ForEach(0..<numRecords, id: \.self) { index in
                        HStack {
                            let resultPokeName = FactorySearcher.getString(pkmnResults[index]["name"])
                           Text("\(resultPokeName)")
                           Spacer()
                        }
                       .contentShape(Rectangle())
                       .onTapGesture {
                           clickedIndex = index
                           pageState = DisplayPage.EntryDetailPage
                        }
                    }
                }
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
        NavigationView
        {
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
                        TextField("Enter pokémon name ", text: $queryName).padding().autocorrectionDisabled(true)
                        TextField("Enter pokémon item ", text: $queryItem).padding().autocorrectionDisabled()
                    }
                }.padding()
                VStack
                {
                    Text("Pokémon Moves")
                    HStack
                    {
                        TextField("Move 1", text: $queryMoves[0]).padding().border(.gray).autocorrectionDisabled()
                        TextField("Move 2", text: $queryMoves[1]).padding().border(.gray).autocorrectionDisabled()
                    }
                    HStack
                    {
                        TextField("Move 3", text: $queryMoves[2]).padding().border(.gray).autocorrectionDisabled()
                        TextField("Move 4", text: $queryMoves[3]).padding().border(.gray).autocorrectionDisabled()
                    }
                }.padding()
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Button("Search")
                {
                    var cppMovesQuery : FactorySearcher.entryList = ["", "", "", ""]
                    for i in (0...(numMoves - 1))
                    {
                        cppMovesQuery[i] = std.string(queryMoves[i])
                    }
                    pkmnSets = factorySearcher.getPossibleSets(std.string(queryName), cppMovesQuery, std.string(queryItem), false, std.string(pokemon_filepath))
                    for entry in pkmnSets
                    {
                        print(FactorySearcher.getString(entry["name"]))
                    }
                    pageState = DisplayPage.ResultsPage
                    
                }
                .frame(width: 200.0, height: 100)
                .background(.red)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
