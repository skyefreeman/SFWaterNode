# SSKWaterSurfaceNode
A 2D water surface implementation for spritekit.

# How to use
Initialize and add to scene:

```
- (void)didMoveToView:(SKView *)view {
    CGPoint startPoint = CGPointMake(0, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    
    SSKWaterSurfaceNode *waterSurface = [SSKWaterSurfaceNode surfaceWithStartPoint:startPoint endPoint:endPoint jointWidth:15];
    [self addChild:self.waterSurface];
}
```

And then in your scene's update method:

```
- (void)update:(CFTimeInterval)currentTime {
     [self.waterSurface update:currentTime];
}
```

Applying a splash:

```
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    [self.waterSurface splash:location speed:-100];
}
```

Adding a body to your surface:

```
- (void)didMoveToView:(SKView *)view {
    CGPoint startPoint = CGPointMake(0, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    
    SSKWaterSurfaceNode *waterSurface = [SSKWaterSurfaceNode surfaceWithStartPoint:startPoint endPoint:endPoint jointWidth:15];
    [waterSurface setBodyWithDepth:self.size.height/2];
    [waterSurface setTexture:[SKTexture textureWithImageNamed:@"imageName"]];
    [self addChild:self.waterSurface];
}
```

# TODO
* Adding droplet splash.
* Allowing for the change of: strokeColor, fillColor

