//
//  RSShapeNode.swift
//  RSShapeNode
//
//  Created by Matthias Fey on 08.09.15.
//  Copyright © 2015 Matthias Fey. All rights reserved.
//

import SpriteKit

/// An `RSShapeNode` object draws a shape by rendering a Core Graphics path
/// offscreen using a disconnected `CAShapeLayer`.  The `CAShapeLayer` is then
/// snapshoted into an image and used as a texture of a `SKSpriteNode`, which
/// is added as a child to the `RSShapeNode`.
/// This technique fixes the insane amount of unfixable bugs of `SKShapeNode`.
/// `RSShapeNode` has nearly the complete functionality of a `SKShapeNode` and
/// has added functionality that is missing in `SKShapeNode`, e.g. repeated
/// textures, shadows, line dash patterns and fill rules.

/// The inspiration of this technique comes from the thread:
/// "`SKShapeNode`, you are dead to me"
/// http://sartak.org/2014/03/skshapenode-you-are-dead-to-me.html
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
    public convenience init(controlPoints points: [CGPoint], closed: Bool = true) {
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
  
        lineCap = LineCap(rawValue: aDecoder.decodeIntegerForKey("lineCap"))!
        lineJoin = LineJoin(rawValue: aDecoder.decodeIntegerForKey("lineJoin"))!
        miterLimit = CGFloat(aDecoder.decodeDoubleForKey("miterLimit"))
        fillRule = FillRule(rawValue: aDecoder.decodeIntegerForKey("fillRule"))!
        
        if let lineDashPattern = aDecoder.decodeObjectForKey("lineDashPattern") as? [NSNumber] { self.lineDashPattern = lineDashPattern.map { CGFloat($0.doubleValue) } }
        lineDashPhase = CGFloat(aDecoder.decodeDoubleForKey("lineDashPhase"))
        strokeStart = CGFloat(aDecoder.decodeDoubleForKey("strokeStart"))
        strokeEnd = CGFloat(aDecoder.decodeDoubleForKey("strokeEnd"))
        
        shadowRadius = CGFloat(aDecoder.decodeDoubleForKey("shadowRadius"))
        if let shadowColor = aDecoder.decodeObjectForKey("shadowColor") as? SKColor { self.shadowColor = shadowColor }
        shadowOpacity = CGFloat(aDecoder.decodeDoubleForKey("shadowOpacity"))
        
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

        aCoder.encodeInteger(lineCap.rawValue, forKey: "lineCap")
        aCoder.encodeInteger(lineJoin.rawValue, forKey: "lineJoin")
        aCoder.encodeDouble(Double(miterLimit), forKey: "miterLimit")
        aCoder.encodeInteger(fillRule.rawValue, forKey: "fillRule")
        
        if lineDashPattern != nil { aCoder.encodeObject(NSArray(array: lineDashPattern!.map { NSNumber(double: Double($0)) }), forKey: "lineDashPattern") }
        aCoder.encodeDouble(Double(lineDashPhase), forKey: "lineDashPhase")
        aCoder.encodeDouble(Double(strokeStart), forKey: "strokeStart")
        aCoder.encodeDouble(Double(strokeEnd), forKey: "strokeEnd")
        
        aCoder.encodeDouble(Double(shadowRadius), forKey: "shadowRadius")
        aCoder.encodeObject(shadowColor, forKey: "shadowColor")
        aCoder.encodeDouble(Double(shadowOpacity), forKey: "shadowOpacity")
        
        aCoder.encodeInteger(blendMode.rawValue, forKey: "blendMode")
        aCoder.encodeObject(shader, forKey: "shader")
        
        if path != nil { aCoder.encodeObject(UIBezierPath(CGPath: path!), forKey: "path") }
    }

    // MARK: Instance variables
    
    /// The path that defines the shape.
    public var path: CGPath? {
        set {
            _path = newValue
            if newValue != nil {
                boundingBox = CGPathGetBoundingBox(path)
                var inverseTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, -1), CGAffineTransformMakeTranslation(-boundingBox.origin.x, boundingBox.size.height+boundingBox.origin.y))
                inversedPath = CGPathCreateCopyByTransformingPath(path, &inverseTransform)
                print(CGPathGetBoundingBox(inversedPath))
            }
            else {
                boundingBox = nil
                inversedPath = nil
            }
            updateShape()
        }
        get { return _path }
    }
    private var _path: CGPath?
    private var boundingBox: CGRect!
    private var inversedPath: CGPath!
    
    /// The color used to fill the shape.  The default fill color is `SKColor.clearColor()`,
    /// which means the shape is not filled.
    public var fillColor: SKColor = SKColor.clearColor() { didSet { updateShape() } }
    
    /// The texture used to fill the shape above its fill color.  The default value is `nil`.
    public var fillTexture: SKTexture? { didSet { updateShape() } }
    
    /// The style used to draw the fill texture.  The default value is `.Scale`, which means
    /// the texture is scaled to fit the shapes bounding box.
    public var fillTextureStyle: TextureStyle = .Scale { didSet { updateShape() } }
    
    /// If the current fill texture style is set to `.Repeat`, the fill texture offset
    /// determines where the texture has its origin.  The default value is `CGPointZero`.
    public var fillTextureOffset: CGPoint = CGPointZero { didSet { updateShape() } }
    
    /// The width used to stroke the path.  The default value is 1.0.
    public var lineWidth: CGFloat = 1.0  { didSet { updateShape() } }
    
    /// The color used to stroke the shape’s path.  The default stroke color is
    /// `SKColor.whiteColor()`.  If you do not want to stroke the shape, use `SKColor.clearColor()`.
    public var strokeColor: SKColor = SKColor.whiteColor()  { didSet { updateShape() } }
    
    /// Specifies the line cap style for the shape’s path.  The line cap style
    /// specifies the shape of the endpoints of an open path when stroked.
    /// The default value is `.Butt`.
    public var lineCap: LineCap = .Butt { didSet { updateShape() } }

    /// Specifies the line join style for the shape’s path.  The line join style
    /// specifies the shape of the joints between connected segments of a stroked path.
    /// The default value is `.Miter`.
    public var lineJoin: LineJoin = .Miter { didSet { updateShape() } }
    
    /// The miter limit used when stroking the shape’s path.
    /// If the current line join style is set to `.Miter`, the miter limit
    /// determines whether the lines should be joined with a bevel instead
    /// of a miter. The length of the miter is divided by the line width.
    /// If the result is greater than the miter limit, the path is drawn with a bevel.
    /// The default value is 10.0.
    public var miterLimit: CGFloat = 10 { didSet { updateShape() } }
    
    /// The fill rule used when filling the shape’s path.
    /// The default value is `.NonZero`.
    public var fillRule: FillRule = .NonZero { didSet { updateShape() } }
    
    /// The dash pattern applied to the shape’s path when stroked.
    /// The dash pattern is specified as an array of `CGFloat` that specify
    /// the lengths of the painted segments and unpainted segments, respectively,
    /// of the dash pattern.  Default is `nil`, a solid line.
    public var lineDashPattern: [CGFloat]? { didSet { updateShape() } }
    
    /// The dash phase applied to the shape’s path when stroked.
    /// Line dash phase specifies how far into the dash pattern the line starts.
    /// The defaut value is 0.0.
    public var lineDashPhase: CGFloat = 0 { didSet { updateShape() } }
    
    /// The relative location at which to begin stroking the path.
    /// The value of this property must be in the range 0.0 to 1.0.
    /// The default value of this property is 0.0.
    public var strokeStart: CGFloat = 0 { didSet { updateShape() } }
    
    /// The relative location at which to stop stroking the path.
    /// The value of this property must be in the range 0.0 to 1.0.
    /// The default value of this property is 1.0.
    public var strokeEnd: CGFloat = 1 { didSet { updateShape() } }
    
    /// The blur radius (in points) used to render the shape’s shadow.
    /// The default value of this property is 0.0.
    public var shadowRadius: CGFloat = 0 { didSet { updateShape() } }
    
    /// The color of the shape’s shadow.  The default value is `SKColor.blackColor()`.
    public var shadowColor: SKColor = SKColor.blackColor() { didSet { updateShape() } }
    
    /// The opacity of the shape’s shadow.  The value in this property
    /// must be in the range 0.0 (transparent) to 1.0 (opaque).
    /// The default value of this property is 1.0.
    public var shadowOpacity: CGFloat = 1 { didSet { updateShape() } }
    
    /// The blend mode used to blend the shape into the parent’s framebuffer.
    /// The default value is `SKBlendModeAlpha`.
    public var blendMode: SKBlendMode {
        set { shape.blendMode = newValue }
        get { return shape.blendMode }
    }
    
    /// A property that determines whether the sprite is rendered using a
    /// custom shader.  The default value is `nil`.
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
            let offset = max(lineWidth*max(1, miterLimit), 2*shadowRadius)
            let frame = CGRect(x: offset, y: offset, width: boundingBox.size.width+2*offset, height: boundingBox.size.height+2*offset)
            
            let parentLayer = CAShapeLayer()
            parentLayer.frame = CGRect(origin: CGPointZero, size: frame.size)
            
            let fillLayer = CAShapeLayer()
            parentLayer.addSublayer(fillLayer)
            fillLayer.frame = frame
            fillLayer.path = inversedPath
            fillLayer.fillColor = fillColor.CGColor
            
            switch fillRule {
            case .NonZero: fillLayer.fillRule = kCAFillRuleNonZero
            case .EvenOdd: fillLayer.fillRule = kCAFillRuleEvenOdd
            }
            
            if shadowRadius > 0 {
                fillLayer.shadowPath = path
                fillLayer.shadowRadius = shadowRadius
                fillLayer.shadowColor = shadowColor.CGColor
                fillLayer.shadowOpacity = Float(shadowOpacity)
            }
            
            if fillTexture != nil {
                let fillTextureLayer = CAShapeLayer()
                parentLayer.addSublayer(fillTextureLayer)
                fillTextureLayer.frame = CGRect(origin: frame.origin, size: boundingBox.size)
                
                switch fillTextureStyle {
                case .Scale: fillTextureLayer.contents = fillTexture?.CGImage
                case .Repeat:
                    let image = fillTexture?.CGImage
                    let width = CGImageGetWidth(image)
                    let height = CGImageGetHeight(image)
                    var offsetX = Int(fillTextureOffset.x)%width
                    if fillTextureOffset.x > 0 { offsetX -= width }
                    var offsetY = Int(-fillTextureOffset.y)%height+Int(boundingBox.size.height)-height
                    if fillTextureOffset.y > 0 { offsetY += height }
                    
                    var x = CGFloat(offsetX)
                    var y = CGFloat(offsetY)
                    while y > CGFloat(-height) {
                        while x < boundingBox.size.width {
                            let layer = CAShapeLayer()
                            layer.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
                            layer.contents = image
                            fillTextureLayer.addSublayer(layer)
                            
                            x += CGFloat(width)
                        }
                        y -= CGFloat(height)
                        x = CGFloat(offsetX)
                    }
                }
                
                let maskLayer = CAShapeLayer()
                maskLayer.frame = CGRect(origin: CGPointZero, size: boundingBox.size)
                maskLayer.path = inversedPath
                maskLayer.fillRule = fillLayer.fillRule
                fillTextureLayer.mask = maskLayer
            }
            
            let strokeLayer = CAShapeLayer()
            parentLayer.addSublayer(strokeLayer)
            strokeLayer.frame = frame
            strokeLayer.path = inversedPath
            strokeLayer.fillColor = UIColor.clearColor().CGColor
            strokeLayer.lineWidth = lineWidth
            strokeLayer.strokeColor = strokeColor.CGColor
            strokeLayer.miterLimit = miterLimit
            strokeLayer.lineDashPattern = lineDashPattern?.map { NSNumber(double: Double($0)) }
            strokeLayer.lineDashPhase = lineDashPhase
            strokeLayer.strokeStart = strokeStart
            strokeLayer.strokeEnd = strokeEnd
            
            switch lineCap {
            case .Butt: strokeLayer.lineCap = kCALineCapButt
            case .Round: strokeLayer.lineCap = kCALineCapRound
            case .Square: strokeLayer.lineCap = kCALineCapSquare
            }
            
            switch lineJoin {
            case .Miter: strokeLayer.lineJoin = kCALineJoinMiter
            case .Round: strokeLayer.lineJoin = kCALineJoinRound
            case .Bevel: strokeLayer.lineJoin = kCALineJoinBevel
            }
            
            UIGraphicsBeginImageContextWithOptions(parentLayer.frame.size, false, UIScreen.mainScreen().scale)
            parentLayer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            shape.size = image.size
            shape.texture = SKTexture(image: image)
            shape.position = CGPoint(x: -frame.origin.x+boundingBox.origin.x, y: -frame.origin.y+boundingBox.origin.y)
        }
        else { shape.removeFromParent() }
    }
}
