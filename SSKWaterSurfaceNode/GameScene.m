//
//  GameScene.m
//  SSKWaterSurfaceNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "GameScene.h"
#import "SSKWaterSurfaceNode.h"

@interface GameScene()
@property (nonatomic) SSKWaterSurfaceNode *waterSurface;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.backgroundColor = [SKColor blackColor];

    CGPoint startPoint = CGPointMake(0, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    
    self.waterSurface = [SSKWaterSurfaceNode withStartPoint:startPoint endPoint:endPoint];
    [self addChild:self.waterSurface];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.waterSurface splash:50 speed:100];
}

-(void)update:(CFTimeInterval)currentTime {
    NSTimeInterval dt = _lastUpdateTime - currentTime;
    _lastUpdateTime = currentTime;
    
    if (dt > 1) {
        dt = 1.0/60.0;
    }
    
    [self.waterSurface update:currentTime];
}

@end
