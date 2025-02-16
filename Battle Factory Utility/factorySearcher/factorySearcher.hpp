//
//  factorySearcher.hpp
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/11/25.
//

#ifndef factorySearcher_hpp
#define factorySearcher_hpp

#include <stdio.h>
#include <vector>
#include <string>
#include <json.hpp>

class FactorySearcher
{
private:
    using json = nlohmann::json;
    
public:

    typedef std::vector<std::string> entryList;
    typedef std::vector<json>      factorySets;
    
    std::vector<json> getPossibleSets(const std::string& pkmnName = "",
                                 const entryList& pkmnMoves = {},
                                 const std::string& pkmnItem = "",
                                 bool exact = false,
                                const std::string& inputPokemonFile = "battle_factory_pokemon.json") const;
    
    static std::string getString(const json& input);
    static std::vector<std::string> getStrings(const json& input);
};


#endif /* factorySearcher_hpp */
