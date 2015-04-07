//
//  GameScene.m
//  SFWaterNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "GameScene.h"
#import "SFWaterNode.h"

@interface GameScene()
@property (nonatomic) SFWaterNode *waterSurface;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [SKColor blackColor];

    CGPoint startPoint = CGPointMake(-1, self.size.height/2);
    CGPoint endPoint = CGPointMake(self.size.width, self.size.height/2);
    
    self.waterSurface = [SFWaterNode nodeWithStartPoint:startPoint endPoint:endPoint depth:self.size.height/2 color:[SKColor blueColor]];
    [self addChild:self.waterSurface];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    [self.waterSurface splash:location speed:-50];
}

- (void)update:(CFTimeInterval)currentTime {
    [self.waterSurface update:currentTime];
}

@end
