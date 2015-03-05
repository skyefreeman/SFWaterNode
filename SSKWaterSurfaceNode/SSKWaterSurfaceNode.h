//
//  SSKWaterSurfaceNode.h
//  SSKWaterSurfaceNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SSKWaterSurfaceNode : SKNode
+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;
- (void)splash:(CGPoint)location speed:(CGFloat)speed;
- (void)update:(NSTimeInterval)dt;

- (void)setSplashDamping:(CGFloat)damping;
- (void)setSplashTension:(CGFloat)tension;

- (void)setBodyWithDepth:(CGFloat)depth;
- (void)setTexture:(SKTexture*)texture; //Only if a depth is set.

@property (nonatomic, readonly) CGFloat jointWidth;
@end

@interface SSKWaterJoint : NSObject
+ (instancetype)jointWithPosition:(CGPoint)position;
- (instancetype)initWithPosition:(CGPoint)position;

@property (nonatomic) CGPoint startPosition;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat damping; // -Default is 0.04;
@property (nonatomic) CGFloat tension; // -Default is 0.03, must be less than damping
@end
