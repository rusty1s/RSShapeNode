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
        //backgroundColor = SKColor.whiteColor()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let node = RSShapeNode()
        let vertices = [CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 100), CGPoint(x: 100, y: 0)]
        
        let path = CGPathCreateMutable()
        
        if vertices.isEmpty {
            CGPathMoveToPoint(path, nil, 0, 0)
        }
        else {
            for (index, vertex) in vertices.enumerate() {
                if index == 0 { CGPathMoveToPoint(path, nil, vertex.x, vertex.y) }
                else { CGPathAddLineToPoint(path, nil, vertex.x, vertex.y) }
            }
            if vertices.count > 2 { CGPathCloseSubpath(path) }
        }
        
        
        node.strokeColor = SKColor.yellowColor()
        node.lineWidth = 10
        node.fillColor = SKColor.redColor()
        //node.lineDashPattern = [15.5, 5.5]
        //node.miterLimit = 20
        //node.lineJoin = RSShapeNode.LineJoin.Round
        //node.lineCap = RSShapeNode.LineCap.Butt
        //node.lineJoin = RSShapeNode.LineJoin.Bevel
        //node.lineDashPhase = 0.5
        //node.lineDashPattern = [1, 2, 1, 2]
        node.path = path
        addChild(node)
        node.position = CGPoint(x: 100, y: 100)
        
        let node2 = SKShapeNode(ellipseOfSize: CGSize(width: 50, height: 200))
        node2.fillColor = SKColor.whiteColor()
        node2.fillTexture = SKTexture(imageNamed: "Spaceship")
        node2.strokeColor = SKColor.yellowColor()
        node2.glowWidth = 15.5
        node.lineWidth = 0
        addChild(node2)
        
    }
}
