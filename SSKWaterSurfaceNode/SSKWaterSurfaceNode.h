//
//  SSKWaterSurfaceNode.h
//  SSKWaterSurfaceNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//The water surface all together
@interface SSKWaterSurfaceNode : SKNode

+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth;

//Splash will cause a ripple starting at the index provided.
- (void)splash:(CGPoint)location speed:(CGFloat)speed;

// Update must be called from the games scene.
- (void)update:(NSTimeInterval)dt;


// JointWidth is the distance between each SSKWaterJoint.  Smaller is more realistic but more GPU intensive.
// -Set at initialization (Recommended 5 - 20)
@property (nonatomic, readonly) CGFloat jointWidth;
@end

//Individual joint springs on water surface
@interface SSKWaterJoint : NSObject

+ (instancetype)jointWithPosition:(CGPoint)position;
- (instancetype)initWithPosition:(CGPoint)position;

@property (nonatomic) CGPoint startPosition;
@property (nonatomic) CGPoint currentPosition;

// Speed is the force at which this spring joint is moving, this will lower over time.
// -Used by SSKWaterSurfaceNode to implement: - (void)splash
@property (nonatomic) CGFloat speed;


// Damping controls the speed at which the wave returns to normal (Higher == deadens out faster)
// -Default is 0.04;
@property (nonatomic) CGFloat damping;

// Tension controls the stiffness of each sprint joint (Higher == small waves that oscillate quickly, Lower == large waves that oscillate slowly)
// -Default is 0.03;
// -Must be less than damping
@property (nonatomic) CGFloat tension;

@end
