//
//  ViewController.swift
//  SceneKitProjectionIssue
//
//  Created by Developer on 12/5/17.
//  Copyright © 2017 MG. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController, SCNSceneRendererDelegate {
    
    var sceneView: SCNView!
    
    var camera: SCNNode!
    
    var motionManager: CMMotionManager!

    var markers = [Marker]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        sceneView = SCNView(frame: self.view.frame)
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = UIColor.red
        self.view.addSubview(sceneView)
        
        let camera = SCNCamera()
        camera.zFar = 10000
        self.camera = SCNNode()
        self.camera.camera = camera
        self.camera.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let ambientLight = SCNLight()
        ambientLight.color = UIColor.white
        ambientLight.type = SCNLight.LightType.directional
        self.camera.light = ambientLight
        
        sceneView.scene?.rootNode.addChildNode(self.camera)
        
        motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue(), withHandler:{
                deviceMotion, error in
                if let motion = deviceMotion {
                    DispatchQueue.main.async {
                    self.camera.orientation = motion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
                    for sm in self.markers
                    {
                            if(sm.marker.superview != nil)
                            {
                                //world coordinates
                                let v1w =  sm.node.convertPosition(sm.node.boundingBox.min, to: self.sceneView.scene?.rootNode)
                                let v2w =  sm.node.convertPosition(sm.node.boundingBox.max, to: self.sceneView.scene?.rootNode)
                                
                                //projected coordinates
                                let v1p = self.sceneView.projectPoint(v1w)
                                let v2p = self.sceneView.projectPoint(v2w)
                                
                                //frame rectangle
                                let rect = CGRect.init(x: CGFloat(v1p.x), y: CGFloat(v2p.y), width: CGFloat(v2p.x - v1p.x), height: CGFloat(v1p.y - v2p.y))
                                
                                var frameOld = sm.marker.frame
                                
                                switch sm.position
                                {
                                case .Top:
                                    frameOld.origin.y = rect.minY - frameOld.size.height/2
                                    frameOld.origin.x = rect.midX - frameOld.size.width/2
                                case .Bottom:
                                    frameOld.origin.y = rect.maxY - frameOld.size.height/2
                                    frameOld.origin.x = rect.midX - frameOld.size.width/2
                                case .Left:
                                    frameOld.origin.y = rect.midY - frameOld.size.height/2
                                    frameOld.origin.x = rect.minX - frameOld.size.width/2
                                case .Right:
                                    frameOld.origin.y = rect.midY - frameOld.size.height/2
                                    frameOld.origin.x = rect.maxX - frameOld.size.width/2
                                }

                                sm.marker.frame = frameOld
                                self.view.layoutSubviews()
                            }
                        }
                    }
                }
                
            })
        }
        sceneView.delegate = self
        addPlane()
    }
    
    var motionLastYaw:Double = 0

    
    func sceneSpacePosition(inFrontOf node: SCNNode, atDistance distance: Float) -> SCNVector3 {
        let localPosition = SCNVector3(x: 0, y: 0, z: -distance)
        let scenePosition = node.convertPosition(localPosition, to: nil)
        // to: nil is automatically scene space
        return scenePosition
    }
    
    func addPlane() {
        
        let plane = SCNNode()
        plane.geometry = SCNPlane.init(width: 100, height: 200)
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.blue
        plane.geometry?.firstMaterial = redMaterial
        plane.orientation = self.camera.orientation
        plane.position = self.sceneSpacePosition(inFrontOf: self.camera, atDistance: 400)
        self.sceneView.scene?.rootNode.addChildNode(plane)
        
        var markers = [Marker]()
        markers.append(Marker(node: plane, position: Side.Top))
        markers.append(Marker(node: plane, position: Side.Left))
        markers.append(Marker(node: plane, position: Side.Right))
        markers.append(Marker(node: plane, position: Side.Bottom))
        for sm in markers
        {
            self.view.addSubview(sm.marker)
        }
        self.markers.append(contentsOf: markers)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sceneView.frame = self.view.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

