//
//  Marker.swift
//  SceneKitProjectionIssue
//
//  Created by Developer on 12/5/17.
//  Copyright © 2017 MG. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

enum Side {
    case Top
    case Left
    case Bottom
    case Right
}

class Marker
{
    var node: SCNNode
    var marker:UIImageView
    var position:Side
    var done:Bool
    
    init(node: SCNNode, position:Side) {
        self.node = node
        let viewCircle = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        viewCircle.image = #imageLiteral(resourceName: "circle").withRenderingMode(.alwaysTemplate)
        viewCircle.tintColor = UIColor.orange
        self.marker = viewCircle
        self.position = position
        self.done = false
    }
}

