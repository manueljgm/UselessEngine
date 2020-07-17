//
//  Observers.swift
//  UselessEngine
//
//  Created by Manny Martins on 12/17/15.
//  Copyright © 2015 Useless Robot. All rights reserved.
//

import Foundation

public class Observers {

    public var headObserver: ObserverNode?
    
    public func addNode(withObserver observer: Observer) {
        let observerNode = ObserverNode(observer: observer)
        observerNode.nextObserver = self.headObserver
        
        self.headObserver = observerNode
    }
    
    public func removeNode(withObserver observer: Observer) {
        guard self.headObserver != nil else {
            return
        }
        
        if self.headObserver!.observer === observer  {
            let nodeToRemove = self.headObserver!
            self.headObserver = nodeToRemove.nextObserver
            nodeToRemove.nextObserver = nil
            
            return
        }
        
        var current = self.headObserver
        while current != nil {
            if current!.nextObserver?.observer === observer {
                let nodeToRemove = current!.nextObserver!
                current!.nextObserver = nodeToRemove.nextObserver
                nodeToRemove.nextObserver = nil
                return
            }
            
            current = current!.nextObserver
        }
    }
    
    public func removeAllNodes() {
        guard var current = self.headObserver else {
            return
        }
        
        while let nextObserver = current.nextObserver {
            current.nextObserver = nil
            current = nextObserver
        }
        
        self.headObserver = nil
    }
    
    public func receive(event: Event, from sender: AnyObject, payload: Any? = nil) {
        var observerNode = self.headObserver
        while observerNode != nil {
            observerNode!.observer.receive(event, from: sender, payload: payload)
            observerNode = observerNode!.nextObserver
        }
    }

}
