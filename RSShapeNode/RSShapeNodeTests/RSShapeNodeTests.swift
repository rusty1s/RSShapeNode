//
//  RSShapeNodeTests.swift
//  RSShapeNodeTests
//
//  Created by Matthias Fey on 08.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import XCTest
import SpriteKit
import RSShapeNode

class RSShapeNodeTests: XCTestCase {
    
    func testShapeNode() {
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
        
        print(path)
        
        node.path = path
    }
}
