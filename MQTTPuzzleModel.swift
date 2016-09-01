//
//  PuzzleModel.swift
//  MQTTCodenames
//
//  Created by Arvin John Tomacruz on 01/09/2016.
//  Copyright © 2016 Voyager Innovations Inc. All rights reserved.
//

import Foundation

struct MQTTPuzzleModel {
    
    private var blueTeamCombinations: [Int]
    private var redTeamCombinations: [Int]
    private var blackSpot: Int
    
    init(blueTeam: [Int], redTeam: [Int], black: Int) {
        blueTeamCombinations = blueTeam
        redTeamCombinations = redTeam
        blackSpot = black
    }
    
    func checkHit(hit: Int) -> TeamHit {
        if (blueTeamCombinations.contains(hit)) {
            return TeamHit.Blue
        }
        else if (redTeamCombinations.contains(hit)) {
            return TeamHit.Red
        }
        else if (blackSpot == hit) {
            return TeamHit.Black
        }
        else {
            return TeamHit.NoTeam
        }
    }
    
}