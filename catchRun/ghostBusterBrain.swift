//
//  ghostBusterBrain.swift
//  catchRun
//
//  Created by Ji Pei on 4/11/15.
//  Copyright (c) 2015 LUSS. All rights reserved.
//

import Foundation

class tileScore : NSObject {
    var coord = CGPoint()
    var score = Int()
    var addedInIteration = Int()
    var parent : tileScore?
    
    override func copy() -> AnyObject {
        var copy = tileScore()
        copy.coord = self.coord
        copy.score = self.score
        copy.addedInIteration = self.addedInIteration
        copy.parent = (self.parent?.copy() as! tileScore)
        return copy
    }
    
}

class ghostBusterBrain : NSObject {
    var physicEngine:CollisionCheck!
    func pathForMovingToPosition(origin: CGPoint, destination: CGPoint) -> Array<CGPoint>{
        // get the current tile coord for node
        let originTileCoord = physicEngine.tileCoordForPosition(origin)
        let destinationTileCoord = physicEngine.tileCoordForPosition(destination)
        var openList : Array<tileScore> = Array()
        var closeList = NSMutableSet()
        var path : Array<CGPoint> = Array()
        
        var currentTS = tileScore()
        currentTS.coord = originTileCoord
        currentTS.score = Int(abs(originTileCoord.x - destinationTileCoord.x) + abs(originTileCoord.y - destinationTileCoord.y))
        currentTS.addedInIteration = 0
        currentTS.parent = nil
        
        var nextCoord = originTileCoord
        var iteration = 0
        
        closeList.addObject(NSValue(CGPoint: originTileCoord))
        while currentTS.coord != destinationTileCoord {
            iteration++
            
            // move down
            nextCoord = currentTS.coord
            nextCoord.y = currentTS.coord.y + 1
            if !closeList.containsObject(NSValue(CGPoint: nextCoord)){
                if !physicEngine.isCollideWithWallAtTile(nextCoord) {
                    // can move to this place cal the score
                    // score is equal to origin to current plus current to destination
                    var g = iteration
                    var h = abs(nextCoord.x - destinationTileCoord.x) + abs(nextCoord.y - destinationTileCoord.y)
                    
                    var ts = tileScore()
                    ts.coord = nextCoord
                    ts.score = g + Int(h)
                    ts.addedInIteration = iteration
                    
                    var copy = tileScore()
                    copy.coord = currentTS.coord
                    copy.score = currentTS.score
                    copy.addedInIteration = currentTS.addedInIteration
                    copy.parent = currentTS.parent
                    
                    ts.parent = copy
                    openList.append(ts)
                    
                }
            }
            
            // move up
            nextCoord.y = currentTS.coord.y - 1
            if !closeList.containsObject(NSValue(CGPoint: nextCoord)){
                if !physicEngine.isCollideWithWallAtTile(nextCoord) {
                    // can move to this place cal the score
                    // score is equal to origin to current plus current to destination
                    var g = iteration
                    var h = abs(nextCoord.x - destinationTileCoord.x) + abs(nextCoord.y - destinationTileCoord.y)
                    
                    var ts = tileScore()
                    ts.coord = nextCoord
                    ts.score = g + Int(h)
                    ts.addedInIteration = iteration
                    
                    var copy = tileScore()
                    copy.coord = currentTS.coord
                    copy.score = currentTS.score
                    copy.addedInIteration = currentTS.addedInIteration
                    copy.parent = currentTS.parent
                    
                    ts.parent = copy
                    openList.append(ts)
                    
                }
            }
            
            // move left
            nextCoord.y = currentTS.coord.y
            nextCoord.x = currentTS.coord.x - 1
            if !closeList.containsObject(NSValue(CGPoint: nextCoord)){
                if !physicEngine.isCollideWithWallAtTile(nextCoord) {
                    // can move to this place cal the score
                    // score is equal to origin to current plus current to destination
                    var g = iteration
                    var h = abs(nextCoord.x - destinationTileCoord.x) + abs(nextCoord.y - destinationTileCoord.y)
                    
                    var ts = tileScore()
                    ts.coord = nextCoord
                    ts.score = g + Int(h)
                    ts.addedInIteration = iteration
                    
                    var copy = tileScore()
                    copy.coord = currentTS.coord
                    copy.score = currentTS.score
                    copy.addedInIteration = currentTS.addedInIteration
                    copy.parent = currentTS.parent
                    
                    ts.parent = copy
                    
                    openList.append(ts)
                    
                }
            }
            // move right
            nextCoord.x = currentTS.coord.x + 1
            if !closeList.containsObject(NSValue(CGPoint: nextCoord)){
                if !physicEngine.isCollideWithWallAtTile(nextCoord) {
                    // can move to this place cal the score
                    // score is equal to origin to current plus current to destination
                    var g = iteration
                    var h = abs(nextCoord.x - destinationTileCoord.x) + abs(nextCoord.y - destinationTileCoord.y)
                    
                    var ts = tileScore()
                    ts.coord = nextCoord
                    ts.score = g + Int(h)
                    ts.addedInIteration = iteration
                    
                    var copy = tileScore()
                    copy.coord = currentTS.coord
                    copy.score = currentTS.score
                    copy.addedInIteration = currentTS.addedInIteration
                    copy.parent = currentTS.parent
                    
                    ts.parent = copy
                    
                    openList.append(ts)
                }
            }
            
            // sort open list by score in ASC order
            openList.sort({ $0.score < $1.score })
            // get the smallest score point
            var ts = openList.first
            // filter openlist to see if there are multiple small vale object
            var filteredArray = openList.filter({$0.score == ts!.score})
            if  filteredArray.count > 1 {
                // multiple same value objects break tie by iteration
                filteredArray.sort({$0.addedInIteration > $1.addedInIteration})
                ts = filteredArray.first
            }
            
            
            // search the object in openlist and delete
            for index in 0...openList.count{
                if openList[index].coord == ts!.coord {
                    if openList[index].addedInIteration == ts!.addedInIteration{
                        openList.removeAtIndex(index)
                        break
                    }
                }
            }
            
            // add into close list
            closeList.addObject(NSValue(CGPoint: ts!.coord))
            
            currentTS = ts!
        }
        
        // reconstruct the path
        while currentTS.coord != originTileCoord {
            path.append(physicEngine!.getCenterForTile(currentTS.coord))
            currentTS = currentTS.parent!
        }
        path.append(physicEngine!.getCenterForTile(originTileCoord))
        path = path.reverse()
        NSLog("\(path.description)")
        
        return path
    }
}










