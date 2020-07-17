////
////  GameEvent.swift
////  UselessEngine
////
////  Created by Manny Martins on 12/9/14.
////  Copyright (c) 2014 Useless Robot. All rights reserved.
////
//
//import SpriteKit
//
//public class GameEvent { // TODO: rename to EventWithAction or something like that
//    
//    let fireDistance: CGFloat
//    
//    private(set) var fired: Bool = false
//    
//    init(fireAtDistance distance: CGFloat) {
//        
//        self.fireDistance = distance
//        
//    }
//    
//    final func doEvent(inWorld world: GameWorld) -> Bool {
//
//        if (!fired) {
//
//            eventDidFire(currentDistance: 0.0, inWorld: world)
//        
//            self.fired = true
//            
//            return true
//        }
//    
//        return false
//    
//    }
//    
//    final func doEvent(currentDistance distance: CGFloat, inWorld world: GameWorld) -> Bool {
//        
//        if (!fired && distance > self.fireDistance) {
//            
//            eventDidFire(currentDistance: distance, inWorld: world)
//            
//            self.fired = true
//            
//            return true
//        }
//        
//        return false
//        
//    }
//    
//    func eventDidFire(currentDistance distance: CGFloat, inWorld world: GameWorld) {
//        fatalError("GameEvent(eventDidFire:inWorld:) has not been implemented")
//    }
//    
//}
