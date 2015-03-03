# SSKWaterSurfaceNode
A 2D water surface implementation for spritekit.

# How to use
Initialize and add to scene:

- (void)didMoveToView:(SKView *)view {
    CGPoint startPoint = CGPointMake(0, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    
    SSKWaterSurfaceNode *waterSurface = [SSKWaterSurfaceNode surfaceWithStartPoint:startPoint endPoint:endPoint jointWidth:15];
    [self addChild:self.waterSurface];
}

And then in your scene's update method:

- (void)update:(CFTimeInterval)currentTime {
     [self.waterSurface update:currentTime];
}
