//
//  pointsCalc.hpp
//  Battle Factory Utility
//
//  Created by Rahul Khandelwal  on 2/18/25.
//

#ifndef pointsCalc_hpp
#define pointsCalc_hpp

#include <stdio.h>
#include <string>

class PointsCalc
{
    
public:
    struct StatsInfo
    {
        int hp;
        int attack;
        int defense;
        int spAttack;
        int spDefense;
        int speed;
    };
    
    // non-HP stat
    static int calcActualStat(const std::string& stat, int evs, int level, int ivs, int basePoints, const std::string& nature);
    
    // only HP stat
    static int calcHPStat(int evs, int level, int ivs, int basePoints);
    
    static StatsInfo getVariantStats(const std::string& data_source, const std::string& name, const StatsInfo& evs, int ivs, int level, const std::string& nature);
    
    static int getVariantStat(const std::string& data_source, const std::string& name, const std::string& stat, int ev, int ivs, int level, const std::string& nature);
};

#endif /* pointsCalc_hpp */
