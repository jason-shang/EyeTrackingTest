//
//  FaceVirtualization.swift
//  EyeTrackingTest
//
//  Created by Jason Shang on 10/29/21.
//

import ARKit
import SceneKit

class TransformVisualization: NSObject, VirtualContentController {
    
    var contentNode: SCNNode?
    
    // Load multiple copies of the axis origin visualization for the transforms this class visualizes.
    lazy var rightEyeNode = SCNReferenceNode()
    lazy var leftEyeNode = SCNReferenceNode()
    
    /// - Tag: ARNodeTracking
    // add a new SceneKit node corresponding to the newly added ARFaceAnchor
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // This class adds AR content only for face anchors.
        guard anchor is ARFaceAnchor else { return nil }
        
        // Load an asset from the app bundle to provide visual content for the anchor.
        contentNode = SCNReferenceNode()
        
        // Add content for eye tracking in iOS 12.
        self.addEyeTransformNodes()
        
        // Provide the node to ARKit for keeping in sync with the face anchor.
        return contentNode
    }

    // Tells the delegate that a SceneKit node's properties have been updated to match the current state of its corresponding anchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
    }
    
    func addEyeTransformNodes() {
        guard #available(iOS 12.0, *), let anchorNode = contentNode else { return }
        
        // Scale down the coordinate axis visualizations for eyes.
        rightEyeNode.simdPivot = float4x4(diagonal: [3, 3, 3, 1])
        leftEyeNode.simdPivot = float4x4(diagonal: [3, 3, 3, 1])
        
        // Add left and right eye nodes as childNodes to the overall contentNode SCCNode (the overall face?)
        anchorNode.addChildNode(rightEyeNode)
        anchorNode.addChildNode(leftEyeNode)
    }

}
