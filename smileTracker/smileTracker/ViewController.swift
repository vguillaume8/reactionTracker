//
//  ViewController.swift
//  smileTracker
//
//  Created by Vince G on 5/13/19.
//  Copyright © 2019 Guillaume Corporations. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    let trackingView = ARSCNView()
    let smileLabel = UILabel()
    let heading = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Device does not support face tracking")
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            
            if(granted){
                
                DispatchQueue.main.sync {
                    self.setupSmileTracker()
                }
                
            }  else {
                fatalError("User did not grant camera permission!")
            }
        }
    }
    
    func setupSmileTracker() {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        trackingView.session.run(configuration)
        trackingView.delegate = self
        
        view.addSubview(trackingView)
        
        
        buildSmileLabel()
        
    }
    
    func buildSmileLabel() {
        
        smileLabel.text = "😑"
        heading.text = "Make a face"
        heading.font = UIFont.systemFont(ofSize: 150)
        smileLabel.font = UIFont.systemFont(ofSize: 150)
        view.addSubview(smileLabel)
        
        // Set constraints
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        smileLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    func handleSmile(smileValue: CGFloat, toungeOut: CGFloat, winked: CGFloat, mouthOpen: CGFloat) {
        
        switch smileValue{
        case _ where toungeOut > 0.5:
            smileLabel.text = "😛"
        case _ where winked > 0.5:
            smileLabel.text = "😉"
        case _ where mouthOpen > 0.5:
            smileLabel.text = "😲"
        case _ where smileValue > 0.5:
        smileLabel.text = "😄"
        case _ where smileValue > 0.2:
        smileLabel.text = "🙂"
        default:
            smileLabel.text = "😑"
            
        }
    }


}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {return}
        
        let leftMouseSmileValue = faceAnchor.blendShapes[.mouthSmileLeft] as! CGFloat
        let rightMouseSmileValue = faceAnchor.blendShapes[.mouthSmileRight] as! CGFloat
        let toungeOut = faceAnchor.blendShapes[.tongueOut] as! CGFloat
        let winked = faceAnchor.blendShapes[.eyeBlinkRight] as! CGFloat
        let mouthOpen = faceAnchor.blendShapes[.jawOpen] as! CGFloat
        
    
        
        
        DispatchQueue.main.sync {
            self.handleSmile(smileValue: (leftMouseSmileValue + rightMouseSmileValue) / 2.0, toungeOut: toungeOut, winked: winked, mouthOpen: mouthOpen)
        }
    }
}

