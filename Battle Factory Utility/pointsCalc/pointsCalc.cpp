//
//  pointsCalc.cpp
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/18/25.
//

#include "pointsCalc.hpp"

#include <unordered_map>
#include <fstream>
#include <json.hpp>

namespace
{

using json = nlohmann::json;

struct NatureInfo
{
    std::string plusStat;
    std::string minusStat;
};

static std::unordered_map<std::string, NatureInfo> natureInfoMap =
{
    {"Hardy", { "attack", "attack" } },
    {"Lonely", { "attack", "defense" } },
    {"Adamant", { "attack", "spAttack" } },
    {"Naughty", { "attack", "spDefense" } },
    {"Brave", { "attack", "speed" } },
    {"Bold", { "defense", "attack" } },
    {"Docile", { "defense", "defense" } },
    {"Impish", { "defense", "spAttack" } },
    {"Lax", { "defense", "spDefense" } },
    {"Relaxed", { "defense", "speed" } },
    {"Modest", { "spAttack", "attack" } },
    {"Mild", { "spAttack", "defense" } },
    {"Bashful", { "spAttack", "spAttack" } },
    {"Rash", { "spAttack", "spDefense" } },
    {"Quiet", { "spAttack", "speed" } },
    {"Calm", { "spDefense", "attack" } },
    {"Gentle", { "spDefense", "defense" } },
    {"Careful", { "spDefense", "spAttack" } },
    {"Quirky", { "spDefense", "spDefense" } },
    {"Sassy", { "spDefense", "speed" } },
    {"Timid", { "speed", "attack" } },
    {"Hasty", { "speed", "defense" } },
    {"Jolly", { "speed", "spAttack" } },
    {"Naive", { "speed", "spDefense" } },
    {"Serious", { "speed", "speed" } },
};

float getNatureMult(const std::string& stat, const std::string& nature)
{
    float multiple = 1;
    if (natureInfoMap.find(nature) != natureInfoMap.end())
    {
        const std::string plusStat = natureInfoMap[nature].plusStat;
        const std::string minusStat = natureInfoMap[nature].minusStat;
        
        if (plusStat == minusStat) multiple = 1;
        else if (plusStat == stat) multiple = 1.1;
        else if (minusStat == stat) multiple = 0.9;
    }
    
    return multiple;
}

} // anonymous namespace

int PointsCalc::calcActualStat(const std::string& stat, int evs, int level, int ivs, int basePoints, const std::string& nature)
{
    return (int(0.01 * (2 * basePoints + ivs + int(evs / 4)) * level) + 5) * getNatureMult(stat, nature);
}

int PointsCalc::calcHPStat(int evs, int level, int ivs, int basePoints)
{
    return int(0.01 * (2 * basePoints + ivs + int(0.25 * evs)) * level) + level + 10;
}

PointsCalc::StatsInfo PointsCalc::getVariantStats(const std::string& data_source, const std::string& name, const StatsInfo& evs, int ivs, int level, const std::string& nature)
{
    StatsInfo defaultStats = {-1, -1, -1, -1, -1, -1};
    
    std::ifstream pokemonFile(data_source);
    if (!pokemonFile) {
        return defaultStats;
    }
    json pokemonData;
    pokemonFile >> pokemonData;
    
    if (pokemonData.find(name) == pokemonData.end())
    {
        return defaultStats;
    }
    
    json entryBaseStats = pokemonData[name];
    const int hpResult = calcHPStat(evs.hp, level, ivs, entryBaseStats["hp"]);
    const int attackResult = calcActualStat("attack", evs.attack, level, ivs, entryBaseStats["attack"], nature);
    const int defenseResult = calcActualStat("defense", evs.defense, level, ivs, entryBaseStats["defense"], nature);
    const int spAttackResult = calcActualStat("spAttack", evs.spAttack, level, ivs, entryBaseStats["spAttack"], nature);
    const int spDefenseResult = calcActualStat("spDefense", evs.spDefense, level, ivs, entryBaseStats["spDefense"], nature);
    const int speedResult = calcActualStat("speed", evs.speed, level, ivs, entryBaseStats["speed"], nature);
    
    return {hpResult, attackResult, defenseResult, spAttackResult, spDefenseResult, speedResult};
}

int PointsCalc::getVariantStat(const std::string& data_source, const std::string& name, const std::string& stat, int ev, int ivs, int level, const std::string& nature)
{
    int defaultStat = ev;
    
    std::ifstream pokemonFile(data_source);
    if (!pokemonFile) {
        return defaultStat;
    }
    json pokemonData;
    pokemonFile >> pokemonData;
    
    if (pokemonData.find(name) == pokemonData.end())
    {
        return defaultStat;
    }
    
    json entryBaseStats = pokemonData[name];
    if (stat == "hp")
    {
        return calcHPStat(ev, level, ivs, entryBaseStats["hp"]);
    }
    
    return calcActualStat(stat, ev, level, ivs, entryBaseStats[stat], nature);
}
