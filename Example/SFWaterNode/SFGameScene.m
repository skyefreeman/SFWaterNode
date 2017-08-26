//
//  GameScene.m
//  SFWaterNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "SFGameScene.h"
@import SFWaterNode;

@interface SFGameScene()
@property (nonatomic) SFWaterNode *waterSurface;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@end

@implementation SFGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [SKColor whiteColor];

    CGPoint startPoint = CGPointMake(-1, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    SKColor *waterColor = [SKColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7];
    
    self.waterSurface = [SFWaterNode nodeWithStartPoint:startPoint
                                               endPoint:endPoint
                                                  depth:self.size.height/2
                                                  color:waterColor];
    [self addChild:self.waterSurface];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    [self.waterSurface splash:location speed:-30];
}

- (void)update:(CFTimeInterval)currentTime {
    [self.waterSurface update:currentTime];
}

@end
