//
//  VirtualContent.swift
//  EyeTrackingTest
//
//  Created by Jason Shang on 10/29/21.
//

import ARKit
import SceneKit

/// For forwarding `ARSCNViewDelegate` messages to the object controlling the currently visible virtual content.
protocol VirtualContentController: ARSCNViewDelegate {
    /// The root node for the virtual content.
    var contentNode: SCNNode? { get set }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
}

func makeController() -> VirtualContentController {
    return TransformVisualization()
}
