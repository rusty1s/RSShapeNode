//
//  Scene.swift
//  Example
//
//  Created by Matthias Fey on 08.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit
import RSShapeNode

class Scene : SKScene {
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.whiteColor()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let vertices = [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 100), CGPoint(x: 200, y: 0)]
        let node = RSShapeNode(points: vertices, closed: true)
        node.strokeColor = SKColor.blackColor()
        node.lineWidth = 20
        node.shadowRadius = 20
        node.shadowColor = SKColor.redColor()
        node.fillColor = SKColor.yellowColor()
        
        addChild(node)
        node.position = CGPoint(x: -100, y: -50)
        
        
    }
}
