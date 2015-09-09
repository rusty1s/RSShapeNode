//
//  RSShapeNode.swift
//  RSShapeNode
//
//  Created by Matthias Fey on 08.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

public class RSShapeNode : SKNode {
    
    public enum LineCap {
        case Butt
        case Round
        case Square
    }
    
    public enum LineJoin {
        case Miter
        case Round
        case Bevel
    }
    
    public enum FillRule {
        case NonZero
        case EvenOdd
    }
    
    // MARK: Initializers
    
    public override init() {
        super.init()
    }
    
    public convenience init(path: CGPath) {
        self.init()
        self.path = path
    }
    
    public init(path: CGPath, centered: Bool) {
        // TODO
        super.init()
    }
    
    public convenience init(rect: CGRect) {
        self.init(path: CGPathCreateWithRect(rect, nil))
    }
    
    public convenience init(rectOfSize size: CGSize) {
        self.init(rect: CGRect(origin: CGPointZero, size: size))
    }
    
    public convenience init(rect: CGRect, cornerRadius radius: CGFloat) {
        self.init(path: CGPathCreateWithRoundedRect(rect, radius, radius, nil))
    }
    
    public convenience init(rectOfSize size: CGSize, cornerRadius radius: CGFloat) {
        self.init(rect: CGRect(origin: CGPointZero, size: size), cornerRadius: radius)
    }
    
    public convenience init(circleOfRadius radius: CGFloat) {
        self.init(ellipseOfSize: CGSize(width: 2*radius, height: 2*radius))
    }
    
    public convenience init(ellipseOfSize size: CGSize) {
        self.init(ellipseInRect: CGRect(origin: CGPointZero, size: size))
    }
    
    public convenience init(ellipseInRect rect: CGRect) {
        self.init(path: CGPathCreateWithEllipseInRect(rect, nil))
    }
    
    public init(points: UnsafeMutablePointer<CGPoint>, count: Int) {
        // TODO
        super.init()
    }
    
    public init(splinePoints points: UnsafeMutablePointer<CGPoint>, count: Int) {
        // TODO
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Instance variables
    
    public var path: CGPath! { didSet { updateShape() } }
    
    public var fillColor: SKColor = SKColor.clearColor() { didSet { updateShape() } }
    
    public var fillTexture: SKTexture? { didSet { updateShape() } }
    
    public var lineWidth: CGFloat = 1.0  { didSet { updateShape() } }
    
    public var strokeColor: SKColor = SKColor.whiteColor()  { didSet { updateShape() } }
    
    public var strokeTexture: SKTexture? { didSet { updateShape() } }
    
    public var lineCap: LineCap = .Butt { didSet { updateShape() } }

    public var lineJoin: LineJoin = .Bevel { didSet { updateShape() } }
    
    public var miterLimit: CGFloat = 0.5 { didSet { updateShape() } }
    
    public var fillRule: FillRule = .NonZero { didSet { updateShape() } }
    
    public var lineDashPattern: [Int]? { didSet { updateShape() } }
    
    public var lineDashPhase: CGFloat = 0 { didSet { updateShape() } }
    
    public var strokeStart: CGFloat = 0 { didSet { updateShape() } }
    
    public var strokeEnd: CGFloat = 1 { didSet { updateShape() } }
    
    public var glowWidth: CGFloat = 0 { didSet { updateShape() } }
    
    public var blendMode: SKBlendMode {
        set { shape.blendMode = newValue }
        get { return shape.blendMode }
    }
    
    public var shader: SKShader? {
        set { shape.shader = newValue }
        get { return shape.shader }
    }
    
    // MARK: Overrides
    
    public override var frame: CGRect { return shape.frame }
    
    // MARK: Helper
    
    private var shape: SKSpriteNode {
        get {
            if let shape = super.childNodeWithName("shape") as? SKSpriteNode { return shape }
            else {
                let shape = SKSpriteNode()
                shape.name = "shape"
                shape.anchorPoint = CGPointZero
                super.addChild(shape)
                return shape
            }
        }
    }
    
    private func updateShape() {
        let shape = self.shape
        
        if path != nil {
            var frame = CGPathGetBoundingBox(path)
            frame = CGRect(x: -frame.origin.x+2*lineWidth, y: -frame.origin.y+2*lineWidth, width: frame.size.width+4*lineWidth, height: frame.size.height+4*lineWidth)
            
            let layer = CAShapeLayer()
            layer.frame = frame
            layer.path = path
            layer.fillColor = fillColor.CGColor
            layer.lineWidth = lineWidth
            layer.strokeColor = strokeColor.CGColor
            layer.miterLimit = miterLimit
            layer.lineDashPattern = lineDashPattern?.map { NSNumber(integer: $0) }
            layer.lineDashPhase = lineDashPhase
            layer.strokeStart = strokeStart
            layer.strokeEnd = strokeEnd
            
            switch lineCap {
            case .Butt: layer.lineCap = kCALineCapButt
            case .Round: layer.lineCap = kCALineCapRound
            case .Square: layer.lineCap = kCALineCapSquare
            }
            
            switch lineJoin {
            case .Miter: layer.lineJoin = kCALineJoinMiter
            case .Round: layer.lineJoin = kCALineJoinRound
            case .Bevel: layer.lineJoin = kCALineJoinBevel
            }
            
            switch fillRule {
            case .NonZero: layer.fillRule = kCAFillRuleNonZero
            case .EvenOdd: layer.fillRule = kCAFillRuleEvenOdd
            }
            
            if glowWidth > 0 {
                // TODO
            }
            
            if fillTexture != nil {
                // TODO
            }
            
            if strokeTexture != nil {
                // TODO
            }
            
            let parentLayer = CAShapeLayer()
            parentLayer.frame = CGRect(origin: CGPointZero, size: frame.size)
            parentLayer.addSublayer(layer)
            
            UIGraphicsBeginImageContextWithOptions(parentLayer.frame.size, false, UIScreen.mainScreen().scale)
            parentLayer.renderInContext(UIGraphicsGetCurrentContext())
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            shape.size = image.size
            shape.yScale = -1
            shape.texture = SKTexture(image: image)
            shape.position = CGPoint(x: -layer.frame.origin.x, y: -layer.frame.origin.y+image.size.height)
        }
        else { shape.removeFromParent() }
    }
}
