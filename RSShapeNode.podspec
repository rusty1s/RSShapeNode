Pod::Spec.new do |s|

  s.name          = "RSShapeNode"
  s.version       = "1.0"
  s.summary       = "A RSShapeNode object draws a shape by rendering a Core Graphics path offscreen using a disconnected CAShapeLayer and snapshots the image to a SKSpriteNode"

  s.description   = <<-DESC
  					A RSShapeNode object draws a shape by rendering a Core Graphics path offscreen using a disconnected CAShapeLayer.  The CAShapeLayer is then snapshoted into an image and used as a texture of a SKSpriteNode, which is added as a child to the RSShapeNode. This technique fixes the insane amount of unfixable bugs and memory leaks of SKShapeNode.
					
					RSShapeNode has nearly the complete functionality of a SKShapeNode plus additional functionality that is missing in SKShapeNode, e.g. repeated textures, shadows, line dash patterns and fill rules.
					DESC

  s.homepage      = "https://github.com/rusty1s/RSShapeNode"
  s.screenshots   = "https://raw.githubusercontent.com/rusty1s/RSShapeNode/master/example.png"

  s.license       = { :type => "MIT", :file => "LICENSE" }

  s.author        = { "Rusty1s" => "matthias.fey@tu-dortmund.de" }

  s.platform      = :ios, "8.0"

  s.source        = { :git => "https://github.com/rusty1s/RSShapeNode.git" }
  s.source_files  = "RSShapeNode/RSShapeNode/*.swift"

end
