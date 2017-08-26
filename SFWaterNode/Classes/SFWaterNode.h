//
//  SFWaterNode.h
//  SFWaterNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SFWaterNode : SKNode

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                           texture:(SKTexture*)texture;

+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                           texture:(SKTexture*)texture;

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                             color:(SKColor*)color;

+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                             color:(SKColor*)color;

/**
 * @brief Updates wave joint locations over time. Required to be called within a SKScene's update method
 */
- (void)update:(NSTimeInterval)dt;

/**
 * @brief Creates a splash at the target point.
 * @param speed The force to apply to the water joint at location.
 */
- (void)splash:(CGPoint)location speed:(CGFloat)speed;

/**
 * @brief Changes the rate at which the wave oscillates.
 * @param damping default == 0.04.
 */
- (void)setSplashDamping:(CGFloat)damping;

/**
 * @brief Changes the "springyness" of the wave.
 * @param tension default == 0.03, must be less than damping to avoid undefined behavior.
 */
- (void)setSplashTension:(CGFloat)tension;


/**
 * @brief Adds a texture to the surface body. Only works if a depth exists.
 */
- (void)setTexture:(SKTexture*)texture;

/** @brief The height of the body of water. */
@property (nonatomic) CGFloat bodyDepth;

/** @brief The distance between the surface's joints. */
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
