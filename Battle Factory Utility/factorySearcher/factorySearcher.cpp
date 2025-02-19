//
//  factorySearcher.cpp
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/11/25.
//

#include "factorySearcher.hpp"
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <algorithm>
#include <cctype>

namespace {

bool isSubstringsSublist(const std::vector<std::string>& substringsList, const std::vector<std::string>& universeList) {
    for (const auto& substring : substringsList) {
        bool found = false;
        for (const auto& entry : universeList) {
            if (entry.find(substring) != std::string::npos) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }
    return true;
}

bool isListSubset(const std::vector<std::string>& portionList, const std::vector<std::string>& universeList) {
    for (const auto& part : portionList) {
        bool found = false;
        for (const auto& entry : universeList) {
            if (part == entry) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }
    return true;
}

std::string to_lower(const std::string& myString)
{
    std::string outString;
    std::transform(myString.begin(), myString.end(), back_inserter(outString),
                   [](unsigned char c){ return std::tolower(c); });
    return std::string(outString);
}

std::vector<std::string> to_lower(const std::vector<std::string>& myStrings)
{
    std::vector<std::string> outStrings;
    for (const std::string& inString : myStrings)
    {
        std::string nString = to_lower(inString);
        outStrings.push_back(to_lower(inString));
    }
    return outStrings;
}

} // anonymous namespace

int FactorySearcher::getInt(const nlohmann::json& input)
{
    return input.get<int>();
}

std::string FactorySearcher::getString(const nlohmann::json& input)
{
    return input.get<std::string>();
}

std::vector<std::string> FactorySearcher::getStrings(const nlohmann::json &input)
{
    return input.get<std::vector<std::string>>();
}

std::vector<FactorySearcher::json> FactorySearcher::getPossibleSets(
                             const std::string& pkmnName,
                             const std::vector<std::string>& pkmnMoves,
                             const std::string& pkmnItem,
                             int roundNumber,
                             bool isFightSeven,
                             bool exact,
                             const std::string& inputPokemonFile) const {
    
    std::string anyMove = "";
    for (const std::string& move : pkmnMoves)
    {
        anyMove += move;
    }
    std::unordered_map<std::string, std::string> qualities = {
        {"name", pkmnName},
        {"moves", pkmnMoves.empty() ? "" : anyMove},
        {"item", pkmnItem}
    };

    bool invalidSearch = true;
    for (const auto& quality : qualities) {
        if (!quality.second.empty()) {
            invalidSearch = false;
            break;
        }
    }
    if (invalidSearch) {
        return {};
    }

    std::ifstream pokemonFile(inputPokemonFile);
    if (!pokemonFile) {
        return {};
    }
    json pokemonData;
    pokemonFile >> pokemonData;

    auto matchOnQualities = [&](const json& pokemonRecord, const std::unordered_map<std::string, std::string>& qualities) {
        std::vector<json> possibilities;
        std::string pName = pokemonRecord["name"];
        std::string qName = qualities.at("name");
        std::vector<std::string> qMoves = pkmnMoves;
        std::string qItem = qualities.at("item");

        bool nameCriteria = qName.empty() ||
            (to_lower(pName).find(to_lower(qName)) != std::string::npos && !exact) ||
            (qName == pName && exact);
        
        std::vector<std::string> qualityMoves;
        if (!qMoves.empty()) {
            if (exact) {
                qualityMoves = qMoves;
            } else {
                for (const auto& move : qMoves) {
                    qualityMoves.push_back(move);
                }
            }
        }

        const size_t numOfVariants = pokemonRecord["variants"].size();
        for (size_t i = 0; i < numOfVariants; i++) {
            int variantNum = int(i) + 1;
            const bool fightSevenNotClause = isFightSeven && roundNumber < 4 && variantNum != roundNumber + 1;
            const bool regularNotClause = (!isFightSeven) && roundNumber < 5 && variantNum != roundNumber && variantNum != (roundNumber - 1);
            if (fightSevenNotClause || regularNotClause)
            {
                continue;
            }
            const auto& variant = pokemonRecord["variants"][i];
            std::vector<std::string> variantMoves = to_lower(variant["moves"].get<std::vector<std::string>>());
            bool movesCriteria = qMoves.empty() ||
                                (!exact && isSubstringsSublist(to_lower(qualityMoves), variantMoves)) ||
                                (exact && isListSubset(qualityMoves, variant["moves"].get<std::vector<std::string>>()));
            bool itemCriteria = qItem.empty() ||
                (to_lower(variant["item"].get<std::string>()).find(to_lower(qItem)) != std::string::npos && !exact) ||
                (qItem == variant["item"] && exact);
            if (nameCriteria && movesCriteria && itemCriteria) {
                json match = variant;
                match["name"] = pName;
                possibilities.push_back(match);
            }
        }
        
        return possibilities;
    };

    std::vector<json> possibleSets;

    for (const auto& pokemon : pokemonData.items()) {
        json pokemonRecord = pokemon.value();
        pokemonRecord["name"] = pokemon.key();
        auto matches = matchOnQualities(pokemonRecord, qualities);
        possibleSets.insert(possibleSets.end(), matches.begin(), matches.end());
    }

    return possibleSets;
}

