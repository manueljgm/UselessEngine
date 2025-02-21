//
//  GameObjectAudioComponent.swift
//  UselessEngine
//
//  Created by Manny Martins on 6/19/21.
//  Copyright © 2021 Useless Robot. All rights reserved.
//

public protocol GameObjectAudioComponent {
    
    func playSound(byID soundID: Int, at gameObject: GameObject, onCompletion: @escaping () -> Void)
    
}
