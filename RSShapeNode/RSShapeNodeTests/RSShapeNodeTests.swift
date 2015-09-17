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
        var node = RSShapeNode()
        XCTAssertEqual(node.children.count, 0)

        node = RSShapeNode(rect: CGRect(x: 10, y: 10, width: 10, height: 10))
        XCTAssertEqual(node.children.count, 1)
        XCTAssertEqual(node.frame, CGRect(x: 0, y: 0, width: 30, height: 30))
        
        node.lineWidth = 10
        XCTAssertEqual(node.frame, CGRect(x: -90, y: -90, width: 210, height: 210))
        
        node.shadowRadius = 200
        XCTAssertEqual(node.frame, CGRect(x: -390, y: -390, width: 810, height: 810))
        
        node.shadowRadius = 0
        node.lineWidth = 0
        node.miterLimit = 0
        XCTAssertEqual(node.frame, CGRect(x: 10, y: 10, width: 10, height: 10))
    }
    
    func testInitializers() {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, 10, 10)
        
        var node = RSShapeNode(path: path)
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 0, y: 0, width: 10, height: 10))
        
        node = RSShapeNode(path: path, centered: true)
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: -5, y: -5, width: 10, height: 10))
        
        node = RSShapeNode(rect: CGRect(x: 10, y: 10, width: 10, height: 10))
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 10, y: 10, width: 10, height: 10))
        
        node = RSShapeNode(rectOfSize: CGSize(width: 10, height: 10))
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: -5, y: -5, width: 10, height: 10))
        
        node = RSShapeNode(rect: CGRect(x: 10, y: 10, width: 10, height: 10), cornerRadius: 5)
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 10, y: 10, width: 10, height: 10))
        
        node = RSShapeNode(rectOfSize: CGSize(width: 10, height: 10), cornerRadius: 5)
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: -5, y: -5, width: 10, height: 10))
        
        node = RSShapeNode(circleOfRadius: 10)
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: -10, y: -10, width: 20, height: 20))
        
        node = RSShapeNode(ellipseOfSize: CGSize(width: 10, height: 20))
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: -5, y: -10, width: 10, height: 20))
        
        node = RSShapeNode(ellipseInRect: CGRect(x: 10, y: 10, width: 10, height: 20))
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 10, y: 10, width: 10, height: 20))
        
        node = RSShapeNode(points: [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 0)])
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 0, y: 0, width: 20, height: 10))
        
        node = RSShapeNode(controlPoints: [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 0)])
        node.miterLimit = 0
        node.lineWidth = 0
        XCTAssertEqual(node.frame, CGRect(x: 0, y: 0, width: 20, height: 10))
    }
}
