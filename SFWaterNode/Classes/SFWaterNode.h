//
//  SFWaterNode.h
//  SFWaterNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SFWaterNode : SKNode

/* 
 Creates a water surface with a given start point, end point, custom joint width, a body depth, and a body texture.
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth texture:(SKTexture*)texture;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth texture:(SKTexture*)texture;

/*
 Creates a water surface with a given start point, end point, a body depth, and a body texture.
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth texture:(SKTexture *)texture;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth texture:(SKTexture *)texture;

/*
 Creates a water surface with a given start point, end point, custom joint width, a body depth, and a body fill color
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth color:(SKColor*)color;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth color:(SKColor*)color;

/*
 Creates a water surface with a given start point, end point, a body depth, and a body fill color
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth color:(SKColor*)color;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth color:(SKColor*)color;

/*
 Creates a water surface with a given start point, end point and custom joint width.
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;

/*
 Creates a water surface with a given start and end point.
 */
+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/* 
 Update is required in the spritekit scene
 */
- (void)update:(NSTimeInterval)dt;

/* 
 Creates a splash at the target point.
 */
- (void)splash:(CGPoint)location speed:(CGFloat)speed;

/* 
 Changes the rate at which the wave oscillates
 @param damping, default == 0.04.
 */
- (void)setSplashDamping:(CGFloat)damping; // -Default is 0.04;

/*
 Changes the "springyness" of the wave
 @param tension, default == 0.03, must be less than @param damping.
 */
- (void)setSplashTension:(CGFloat)tension;

/* 
 Adds a body to the surface, use if the surface is already initialized.
 */
- (void)setBodyWithDepth:(CGFloat)depth;

/* 
 Adds a texture to the surface body.  Only works if a depth exists.
 */
- (void)setTexture:(SKTexture*)texture;

/*
 The distance between the surface's joints
 */
@property (nonatomic, readonly) CGFloat jointWidth;

@end

@interface SFWaterJoint : NSObject
+ (instancetype)jointWithPosition:(CGPoint)position;
- (instancetype)initWithPosition:(CGPoint)position;

@property (nonatomic) CGPoint startPosition;
@property (nonatomic) CGPoint currentPosition;
@property (nonatomic) CGFloat speed;
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat tension;
@end
