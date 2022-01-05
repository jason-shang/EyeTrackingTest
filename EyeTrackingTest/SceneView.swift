//
//  FaceViewController.swift
//  EyeTrackingTest
//
//  Created by Jason Shang on 10/29/21.
//

import ARKit
import SwiftUI
import SceneKit
import UIKit
import Foundation

// MARK: - sceneViewIndicator
// used for wrapping UIKit UIViewController type (sceneView class below) into SwiftUI

struct SceneViewIndicator: UIViewControllerRepresentable {
   typealias UIViewControllerType = SceneView
   
   func makeUIViewController(context: Context) -> SceneView {
      return SceneView()
   }
    
   func updateUIViewController(_ uiViewController:
   SceneViewIndicator.UIViewControllerType, context:
   UIViewControllerRepresentableContext<SceneViewIndicator>) {}
}

// MARK: sceneView
class SceneView: UIViewController, ARSCNViewDelegate {
    
    var sceneView: ARSCNView {
        return self.view as! ARSCNView
    }
    
    override func loadView() {
        self.view = ARSCNView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        
        sceneView.automaticallyUpdatesLighting = true
    }

    // MARK: - Functions for standard AR view handling
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // AR experiences typically involve moving the device without
        // touch input for some time, so prevent auto screen dimming.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // "Reset" to run the AR session for the first time.
        resetTracking()
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        }
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      let configuration = ARWorldTrackingConfiguration()
      sceneView.session.run(configuration)
      sceneView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func sessionWasInterrupted(_ session: ARSession) {}

    func sessionInterruptionEnded(_ session: ARSession) {}
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState
    camera: ARCamera) {}
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    let contentController = TransformVisualization()
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // If this is the first time with this anchor, get the controller to create content.
        // Otherwise (switching content), will change content when setting `selectedVirtualContent`.
        DispatchQueue.main.async {
            //let contentController = self.selectedVirtualContent.makeController()
            if node.childNodes.isEmpty, let contentNode = self.contentController.renderer(renderer, nodeFor: faceAnchor) {
                node.addChildNode(contentNode)
                //self.faceAnchorsAndContentControllers[faceAnchor] = contentController
            }
        }
    }
    
    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            //let contentController = faceAnchorsAndContentControllers[faceAnchor],
            let contentNode = contentController.contentNode else {
            return
        }
        
        self.contentController.renderer(renderer, didUpdate: contentNode, for: anchor)
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
//
//        faceAnchorsAndContentControllers[faceAnchor] = nil
//    }
}
