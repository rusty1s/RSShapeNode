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
        
        let vertices = [CGPoint(x: -100, y: 0), CGPoint(x: 0, y: 100), CGPoint(x: 100, y: 0), CGPoint(x: 0, y: -100)]
        let node = RSShapeNode(points: vertices, closed: true)
        
        node.fillColor = SKColor.yellowColor()
        node.fillTexture = SKTexture(imageNamed: "Stripe")
        node.fillTextureStyle = .Repeat
        node.fillTextureOffset = CGPoint(x: 100, y: 100)
        
        node.lineWidth = 10
        node.strokeColor = SKColor.whiteColor()
        
        node.shadowRadius = 10
        node.shadowColor = SKColor.blackColor()
        node.shadowOpacity = 1
        
        addChild(node)
    }
}
