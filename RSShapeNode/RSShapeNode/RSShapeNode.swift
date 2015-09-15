//
//  RSShapeNode.swift
//  RSShapeNode
//
//  Created by Matthias Fey on 08.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

public class RSShapeNode : SKNode {
    
    public enum TextureStyle : Int {
        case Scale
        case Repeat
    }
    
    public enum LineCap : Int {
        case Butt
        case Round
        case Square
    }
    
    public enum LineJoin : Int {
        case Miter
        case Round
        case Bevel
    }
    
    public enum FillRule : Int {
        case NonZero
        case EvenOdd
    }
    
    // MARK: Initializers
    
    public override init() {
        super.init()
    }
    
    /// Creates a shape node from a Core Graphics path.
    public convenience init(var path: CGPath, centered: Bool = false) {
        if centered {
            let frame = CGPathGetBoundingBox(path)
            var transform = CGAffineTransformMakeTranslation(-frame.origin.x-frame.size.width/2, -frame.origin.y-frame.size.height/2)
            path = CGPathCreateCopyByTransformingPath(path, &transform)!
        }
        
        self.init()
        self.path = path
    }
    
    /// Creates a shape node with a rectangular path.
    public convenience init(rect: CGRect) {
        self.init(path: CGPathCreateWithRect(rect, nil))
    }
    
    /// Creates a shape node with a rectangular path centered on the node’s origin.
    public convenience init(rectOfSize size: CGSize) {
        self.init(rect: CGRect(origin: CGPointZero, size: size))
    }
    
    /// Creates a shape with a rectangular path with rounded corners.
    public convenience init(rect: CGRect, cornerRadius radius: CGFloat) {
        self.init(path: CGPathCreateWithRoundedRect(rect, radius, radius, nil))
    }
    
    /// Creates a shape with a rectangular path with rounded corners centered on the node’s origin.
    public convenience init(rectOfSize size: CGSize, cornerRadius radius: CGFloat) {
        self.init(rect: CGRect(origin: CGPointZero, size: size), cornerRadius: radius)
    }
    
    /// Creates a shape node with a circular path centered on the node’s origin.
    public convenience init(circleOfRadius radius: CGFloat) {
        self.init(ellipseOfSize: CGSize(width: 2*radius, height: 2*radius))
    }
    
    /// Creates a shape node with an elliptical path centered on the node’s origin.
    public convenience init(ellipseOfSize size: CGSize) {
        self.init(ellipseInRect: CGRect(origin: CGPointZero, size: size))
    }
    
    /// Creates a shape node with an elliptical path that fills the specified rectangle.
    public convenience init(ellipseInRect rect: CGRect) {
        self.init(path: CGPathCreateWithEllipseInRect(rect, nil))
    }
    
    /// Creates a shape node from a series of points.
    public convenience init(points: [CGPoint], closed: Bool = true) {
        if points.isEmpty { self.init() }
        else {
            let path = CGPathCreateMutable()
            
            for (index, point) in points.enumerate() {
                if index == 0 { CGPathMoveToPoint(path, nil, point.x, point.y) }
                else { CGPathAddLineToPoint(path, nil, point.x, point.y) }
            }
            if closed && points.count > 2 { CGPathCloseSubpath(path) }
            
            self.init(path: path)
        }
    }
    
    /// Creates a shape node with a quadratic Bézier curve from a series of control points.
    public convenience init(controlPoints points: [CGPoint], closed: Bool = false) {
        if points.isEmpty { self.init() }
        else {
            let path = CGPathCreateMutable()
            
            func midBetweenPoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
                return CGPoint(x: (point1.x+point2.x)/CGFloat(2), y: (point1.y+point2.y)/CGFloat(2))
            }
            
            var prevPoint = points.last!
            for (index, point) in points.enumerate() {
                let mid = midBetweenPoint(prevPoint, point2: point)
                
                if index == 0 {
                    if closed && points.count > 2 { CGPathMoveToPoint(path, nil, mid.x, mid.y) }
                    else { CGPathMoveToPoint(path, nil, point.x, point.y) }
                }
                else {  CGPathAddQuadCurveToPoint(path, nil, prevPoint.x, prevPoint.y, mid.x, mid.y) }
                
                prevPoint = point
            }
            
            if closed && points.count > 2 {
                let mid = midBetweenPoint(prevPoint, point2: points.first!)
                CGPathAddQuadCurveToPoint(path, nil, prevPoint.x, prevPoint.y, mid.x, mid.y)
                CGPathCloseSubpath(path)
            }
            else { CGPathAddLineToPoint(path, nil, prevPoint.x, prevPoint.y) }
            
            self.init(path: path)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        
        if let fillColor = aDecoder.decodeObjectForKey("fillColor") as? SKColor { self.fillColor = fillColor }
        if let fillTexture = aDecoder.decodeObjectForKey("fillTexture") as? SKTexture { self.fillTexture = fillTexture }
        fillTextureStyle = TextureStyle(rawValue: aDecoder.decodeIntegerForKey("fillTextureStyle"))!
        fillTextureOffset = aDecoder.decodeCGPointForKey("fillTextureOffset")
        
        lineWidth = CGFloat(aDecoder.decodeDoubleForKey("lineWidth"))
        if let strokeColor = aDecoder.decodeObjectForKey("strokeColor") as? SKColor { self.strokeColor = strokeColor }
        if let strokeTexture = aDecoder.decodeObjectForKey("strokeTexture") as? SKTexture { self.strokeTexture = strokeTexture }
        strokeTextureStyle = TextureStyle(rawValue: aDecoder.decodeIntegerForKey("strokeTextureStyle"))!
        strokeTextureOffset = aDecoder.decodeCGPointForKey("strokeTextureOffset")
        
        lineCap = LineCap(rawValue: aDecoder.decodeIntegerForKey("lineCap"))!
        lineJoin = LineJoin(rawValue: aDecoder.decodeIntegerForKey("lineJoin"))!
        miterLimit = CGFloat(aDecoder.decodeDoubleForKey("miterLimit"))
        fillRule = FillRule(rawValue: aDecoder.decodeIntegerForKey("fillRule"))!
        
        if let lineDashPattern = aDecoder.decodeObjectForKey("lineDashPattern") as? [NSNumber] { self.lineDashPattern = lineDashPattern.map { CGFloat($0.doubleValue) } }
        lineDashPhase = CGFloat(aDecoder.decodeDoubleForKey("lineDashPhase"))
        strokeStart = CGFloat(aDecoder.decodeDoubleForKey("strokeStart"))
        strokeEnd = CGFloat(aDecoder.decodeDoubleForKey("strokeEnd"))
        
        glowWidth = CGFloat(aDecoder.decodeDoubleForKey("glowWidth"))
        if let glowColor = aDecoder.decodeObjectForKey("glowColor") as? SKColor { self.glowColor = glowColor }
        
        blendMode = SKBlendMode(rawValue: aDecoder.decodeIntegerForKey("blendMode"))!
        if let shader = aDecoder.decodeObjectForKey("shader") as? SKShader { self.shader = shader }
        
        if let path = aDecoder.decodeObjectForKey("path") as? UIBezierPath { self.path = path.CGPath }
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(fillColor, forKey: "fillColor")
        aCoder.encodeObject(fillTexture, forKey: "fillTexture")
        aCoder.encodeInteger(fillTextureStyle.rawValue, forKey: "fillTextureStyle")
        aCoder.encodeCGPoint(fillTextureOffset, forKey: "fillTextureOffset")
        
        aCoder.encodeDouble(Double(lineWidth), forKey: "lineWidth")
        aCoder.encodeObject(strokeColor, forKey: "strokeColor")
        aCoder.encodeObject(strokeTexture, forKey: "strokeTexture")
        aCoder.encodeInteger(strokeTextureStyle.rawValue, forKey: "strokeTextureStyle")
        aCoder.encodeCGPoint(strokeTextureOffset, forKey: "strokeTextureOffset")
        
        aCoder.encodeInteger(lineCap.rawValue, forKey: "lineCap")
        aCoder.encodeInteger(lineJoin.rawValue, forKey: "lineJoin")
        aCoder.encodeDouble(Double(miterLimit), forKey: "miterLimit")
        aCoder.encodeInteger(fillRule.rawValue, forKey: "fillRule")
        
        if lineDashPattern != nil { aCoder.encodeObject(NSArray(array: lineDashPattern!.map { NSNumber(double: Double($0)) }), forKey: "lineDashPattern") }
        aCoder.encodeDouble(Double(lineDashPhase), forKey: "lineDashPhase")
        aCoder.encodeDouble(Double(strokeStart), forKey: "strokeStart")
        aCoder.encodeDouble(Double(strokeEnd), forKey: "strokeEnd")
        
        aCoder.encodeDouble(Double(glowWidth), forKey: "glowWidth")
        aCoder.encodeObject(glowColor, forKey: "glowColor")
        
        aCoder.encodeInteger(blendMode.rawValue, forKey: "blendMode")
        aCoder.encodeObject(shader, forKey: "shader")
        
        if path != nil { aCoder.encodeObject(UIBezierPath(CGPath: path!), forKey: "path") }
    }

    // MARK: Instance variables
    
    public var path: CGPath? { didSet { updateShape() } }
    
    public var fillColor: SKColor = SKColor.clearColor() { didSet { updateShape() } }
    
    public var fillTexture: SKTexture? { didSet { updateShape() } }
    
    public var fillTextureStyle: TextureStyle = .Scale { didSet { updateShape() } }
    
    public var fillTextureOffset: CGPoint = CGPointZero { didSet { updateShape() } }
    
    public var lineWidth: CGFloat = 1.0  { didSet { updateShape() } }
    
    public var strokeColor: SKColor = SKColor.whiteColor()  { didSet { updateShape() } }
    
    public var strokeTexture: SKTexture? { didSet { updateShape() } }
    
    public var strokeTextureStyle: TextureStyle = .Scale { didSet { updateShape() } }
    
    public var strokeTextureOffset: CGPoint = CGPointZero { didSet { updateShape() } }
    
    public var lineCap: LineCap = .Butt { didSet { updateShape() } }

    public var lineJoin: LineJoin = .Miter { didSet { updateShape() } }
    
    public var miterLimit: CGFloat = 10 { didSet { updateShape() } }
    
    public var fillRule: FillRule = .NonZero { didSet { updateShape() } }
    
    public var lineDashPattern: [CGFloat]? { didSet { updateShape() } }
    
    public var lineDashPhase: CGFloat = 0 { didSet { updateShape() } }
    
    public var strokeStart: CGFloat = 0 { didSet { updateShape() } }
    
    public var strokeEnd: CGFloat = 1 { didSet { updateShape() } }
    
    public var glowWidth: CGFloat = 0 { didSet { updateShape() } }
    
    public var glowColor: SKColor = SKColor.blackColor() { didSet { updateShape() } }
    
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
            var frame = CGPathGetBoundingBox(path!)
            frame = CGRect(x: -frame.origin.x+2*lineWidth, y: -frame.origin.y+2*lineWidth, width: frame.size.width+4*lineWidth, height: frame.size.height+4*lineWidth)
            
            let layer = CAShapeLayer()
            layer.frame = frame
            layer.path = path
            layer.fillColor = fillColor.CGColor
            layer.lineWidth = lineWidth
            layer.strokeColor = strokeColor.CGColor
            layer.miterLimit = miterLimit
            layer.lineDashPattern = lineDashPattern?.map { NSNumber(double: Double($0)) }
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
            parentLayer.renderInContext(UIGraphicsGetCurrentContext()!)
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
