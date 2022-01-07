//
//  Eye.swift
//  EyeTrackingTest
//
//  Created by Jason Shang on 1/7/22.
//

import Foundation
import SceneKit
import ARKit

// stores eye-tracking related data for each eye
public class Eye {
    public var lookPoints: [CGPoint] = []
    public var timestamps: [TimeInterval] = []
    public var numBlinks: Int = 0
    
    // extract information from the left and right eye nodes and update that info in the class
//    func update( value :  ) {
//        lookPoints.append()
//    }
}
