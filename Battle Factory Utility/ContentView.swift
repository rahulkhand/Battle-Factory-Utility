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
let pStats_filepath = Bundle.main.path(forResource: "base_stats_pokemon.json", ofType: nil) ?? ""
let factorySearcher = FactorySearcher()
let numMoves = 4

enum DisplayPage {
    case SearchPage
    case ResultsPage
    case EntryDetailPage
}

extension Color {
    static var searchBoxBg: Color { Color (red: 0.172, green: 0.172, blue: 0.18) }
}

func getEvFromRound (round: Int, isFightSeven: Bool) -> Int32 {
    if (round >= 8)
    {
        return 31
    }
    return Int32((round - (isFightSeven ? 0 : 1)) * 4)
}

public extension Binding {

    static func convert<TInt, TFloat>(_ intBinding: Binding<TInt>) -> Binding<TFloat>
    where TInt:   BinaryInteger,
          TFloat: BinaryFloatingPoint{

        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }

    static func convert<TFloat, TInt>(_ floatBinding: Binding<TFloat>) -> Binding<TInt>
    where TFloat: BinaryFloatingPoint,
          TInt:   BinaryInteger {

        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
}

struct ContentView: View {
    @State private var pageState : DisplayPage = DisplayPage.SearchPage
    @State private var queryName = ""
    @State private var queryItem = ""
    @State private var queryMoves = [String](repeating: "", count: numMoves)
    @State private var pkmnSets = FactorySearcher.factorySets()
    @State private var selectedEntryIndex : Int?
    @State private var roundNumber : Int = 1
    @State private var fightSevenEnabled : Bool = false
    
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
                    SearchView(pkmnSets: $pkmnSets, queryName: $queryName, queryItem: $queryItem, queryMoves: $queryMoves, pageState: $pageState, roundNumber: $roundNumber, fightSevenEnabled: $fightSevenEnabled)
                }
                else if (pageState == DisplayPage.ResultsPage)
                {
                    ResultsView(pkmnResults: $pkmnSets, pageState: $pageState, clickedIndex: $selectedEntryIndex)
                }
                else if (pageState == DisplayPage.EntryDetailPage)
                {
                    EntryDetailView(pokemonRecord: pkmnSets[selectedEntryIndex!], pageState: $pageState, roundNumber: $roundNumber, isFightSeven: fightSevenEnabled)
                }
            }
        }
    }
}

struct EntryDetailView: View {
    var pokemonRecord : json
    @Binding var pageState : DisplayPage
    @Binding var roundNumber : Int
    var isFightSeven : Bool
    
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
                                let ev = FactorySearcher.getInt(pokemonRecord["evs"][std.string(statClasses[index])])
                                let statValue = PointsCalc.getVariantStat(std.string(pStats_filepath), std.string(resultName), std.string(statClasses[index]), ev, getEvFromRound(round: roundNumber, isFightSeven: isFightSeven), 100, std.string(resultNature))
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
    @Binding var roundNumber : Int
    @Binding var fightSevenEnabled : Bool
    
    var body: some View {
        VStack (spacing: 0)
        {
            HStack
            {
                Text("Set Number: \((roundNumber == 8) ? "8+" : String(roundNumber))").foregroundStyle(.white)
                Slider(value: .convert($roundNumber), in: 1.0...8.0, step: 1.0)
                    {
                        Text("Set Number")
                    }
                Button
                {
                    fightSevenEnabled = !fightSevenEnabled
                } label : {
                    Text("Fight 7").padding(5).foregroundStyle(fightSevenEnabled ? .white : .gray)
                }.border(fightSevenEnabled ? .white : .gray).background(fightSevenEnabled ? .orange : .clear)
            }.padding([.horizontal, .top], 10).background(Color.searchBoxBg).opacity(0.9)
            HStack
            {
                VStack (spacing: 0)
                {
                    Text("Pokémon Name").padding().foregroundStyle(.white)
                    Text("Pokémon Item").foregroundStyle(.white).padding()
                }
                VStack (spacing : 0)
                {
                    TextField("Enter name ", text: $queryName).padding().autocorrectionDisabled().foregroundStyle(.white)
                    TextField("Enter item ", text: $queryItem).padding().autocorrectionDisabled().foregroundStyle(.white)
                }
            }.background(Color.searchBoxBg).opacity(0.9)
            VStack (spacing: 0)
            {
                Text("Pokémon Moves").foregroundStyle(.white)
                HStack
                {
                    TextField("Move 1", text: $queryMoves[0]).padding().border(.blue).foregroundStyle(.white).autocorrectionDisabled()
                    TextField("Move 2", text: $queryMoves[1]).padding().border(.blue).foregroundStyle(.white).autocorrectionDisabled()
                }.opacity(0.8).padding(.top, 10)
                HStack
                {
                    TextField("Move 3", text: $queryMoves[2]).padding().border(.blue).foregroundStyle(.white).autocorrectionDisabled()
                    TextField("Move 4", text: $queryMoves[3]).padding().border(.blue).foregroundStyle(.white).autocorrectionDisabled()
                }.padding(.bottom, 10)
                Button
                {
                    for i in (0...(numMoves - 1)) {
                        queryMoves[i] = ""
                    }
                    queryName = ""
                    queryItem = ""
                    
                } label : {
                    Text("Clear All").foregroundStyle(.red)
                }
            }.padding().background(Color.searchBoxBg).opacity(0.9)
            
            Button {
                var cppMovesQuery : FactorySearcher.entryList = ["", "", "", ""]
                for i in (0...(numMoves - 1))
                {
                    cppMovesQuery[i] = std.string(queryMoves[i])
                }
                pkmnSets = factorySearcher.getPossibleSets(std.string(queryName), cppMovesQuery, std.string(queryItem), Int32(roundNumber), fightSevenEnabled, false, std.string(pokemon_filepath))
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
