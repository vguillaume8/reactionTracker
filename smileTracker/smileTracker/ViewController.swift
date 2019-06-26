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
    let change = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
    
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
        let heading = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        heading.center = CGPoint(x: 160, y: 285)
        heading.textAlignment = .center
        heading.text = "Make A Face"
        
       
        change.center = CGPoint(x: 160, y: 600)
        change.textAlignment = .center
        change.text = ""
        view.addSubview(change)
        
        smileLabel.font = UIFont.systemFont(ofSize: 150)
        view.addSubview(heading)
        view.addSubview(smileLabel)
        
        // Set constraints
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        smileLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    func handleSmile(smileValue: CGFloat, toungeOut: CGFloat, winked: CGFloat,
                     mouthOpen: CGFloat, eyebrows: CGFloat, eyesLookedDown: CGFloat) {
        
        switch smileValue{
        case _ where eyebrows > 1:
            smileLabel.text = "🤨"
            change.text = "Eyebrows up"
            view.addSubview(change)
        case _ where eyesLookedDown > 1:
            smileLabel.text = "😌"
            change.text = "Eyes closed"
            view.addSubview(change)
        case _ where toungeOut > 0.5:
            smileLabel.text = "😛"
            change.text = "Toungue Out"
            view.addSubview(change)
        case _ where winked > 0.5:
            smileLabel.text = "😉"
            change.text = "Winked"
            view.addSubview(change)
        case _ where mouthOpen > 0.5:
            smileLabel.text = "😲"
            change.text = "Mouth Open"
            view.addSubview(change)
        case _ where smileValue > 0.5:
        smileLabel.text = "😄"
        change.text = "Big Smile"
        view.addSubview(change)
        case _ where smileValue > 0.2:
        smileLabel.text = "🙂"
        change.text = "Small Smile"
        view.addSubview(change)
        default:
            smileLabel.text = "😑"
            change.text = "Straight Face"
            view.addSubview(change)
            
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
        let eyesLookedDownLeft = faceAnchor.blendShapes[.eyeLookDownLeft] as! CGFloat
        let eyesLookedDownRight = faceAnchor.blendShapes[.eyeLookDownRight] as! CGFloat
        let eyesLookedDown = eyesLookedDownLeft + eyesLookedDownRight
        let eyebrowsRight = faceAnchor.blendShapes[.browOuterUpRight] as! CGFloat
        let eyebrowsLeft = faceAnchor.blendShapes[.browOuterUpLeft] as! CGFloat
        let eyebrows = eyebrowsRight + eyebrowsLeft
     
        
    
        
        
        DispatchQueue.main.sync {
            self.handleSmile(smileValue: (leftMouseSmileValue + rightMouseSmileValue) / 2.0, toungeOut: toungeOut, winked: winked, mouthOpen: mouthOpen, eyebrows: eyebrows, eyesLookedDown: eyesLookedDown)
        }
    }
}

