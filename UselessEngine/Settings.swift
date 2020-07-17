//
//  Settings.swift
//  UselessEngine
//
//  Created by Manny Martins on 9/14/18.
//  Copyright © 2018 Useless Robot. All rights reserved.
//

struct Settings {
    struct defaults {
        struct graphics {
            static internal var animationFrameRate: UInt8 = 10
        }
    }
}

public struct UselessEngine {
    public struct settings {
        public static func setDefault(animationFrameRate newFrameRate: UInt8) {
            Settings.defaults.graphics.animationFrameRate = newFrameRate
        }
    }
}
