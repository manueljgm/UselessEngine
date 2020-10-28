//
//  Settings.swift
//  UselessEngine
//
//  Created by Manny Martins on 9/14/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

enum Settings
{
    enum defaults {
        enum graphics {
            static internal var animationFrameRate: UInt8 = 10
        }
        enum physics {
            static internal var minimumBoostDecayValue: Float = 0.1
        }
    }
}

public enum UselessEngine
{
    public enum settings
    {
        public static func setDefault(animationFrameRate newValue: UInt8)
        {
            Settings.defaults.graphics.animationFrameRate = newValue
        }
        
        public static func setDefault(minimumBoostDecayValue newValue: Float)
        {
            guard newValue > 0.0 else {
                return
            }

            Settings.defaults.physics.minimumBoostDecayValue = newValue
        }
    }
}
