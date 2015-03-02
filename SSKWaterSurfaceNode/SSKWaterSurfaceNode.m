//
//  SSKWaterSurfaceNode.m
//  SSKWaterSurfaceNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "SSKWaterSurfaceNode.h"

CGFloat const kJointWidth = 10;

//Hooke's law a = -k/m * x
@implementation SSKWaterJoint
+ (instancetype)withPosition:(CGPoint)position {
    return [[self alloc] initWithPosition:position];
}

- (instancetype)initWithPosition:(CGPoint)position {
    self = [super init];
    if (self) {
        self.startPosition = position;
        self.currentPosition = position;
        self.speed = 0;
    }
    return self;
}

- (void)update:(NSTimeInterval)dt {
    CGFloat d = 0.025;
    CGFloat k = 0.025;
    CGFloat x = self.currentPosition.y - self.startPosition.y;
    CGFloat acceleration = -k * x;
    
    self.currentPosition = CGPointMake(self.currentPosition.x, self.currentPosition.y + self.speed);
    self.speed += acceleration - d;
}
@end

@interface SSKWaterSurfaceNode()
@property (nonatomic) NSMutableArray *waterJoints;
@property (nonatomic) SKShapeNode *waterSurface;
@property (nonatomic) CGFloat spread;
@end

@implementation SSKWaterSurfaceNode
+ (instancetype)withStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint];
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    self = [super init];
    if (self) {
        self.spread = 0.4;
        
        self.waterJoints = [self createSurfacePointsWithStart:startPoint end:endPoint];
        self.waterSurface = [SKShapeNode shapeNodeWithPath:[self pathFromJoints:self.waterJoints]];
        [self addChild:self.waterSurface];
    }
    
    return self;
}

#pragma mark - Water joint creation
- (NSMutableArray*)createSurfacePointsWithStart:(CGPoint)startPoint end:(CGPoint)endPoint {
    NSMutableArray *tempPoints = [NSMutableArray new];
    [tempPoints addObject:[SSKWaterJoint withPosition:startPoint]];
    
    //Get distance between points
    double distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2));
    
    //Get angle between start and end
    double rads = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);

    CGFloat totalWidth = 0;
    for (int i = 1; totalWidth < distance; i++) {
        totalWidth += kJointWidth;
        
        double nextX = startPoint.x + totalWidth * cos(rads);
        double nextY = startPoint.y + totalWidth * sin(rads);
        [tempPoints insertObject:[SSKWaterJoint withPosition:CGPointMake(nextX, nextY)] atIndex:i];
    }
    
    return [NSMutableArray arrayWithArray:tempPoints];
}

- (CGPathRef)pathFromJoints:(NSArray*)joints {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, [(SSKWaterJoint*)[joints objectAtIndex:0] currentPosition].x,[(SSKWaterJoint*)[joints objectAtIndex:0] currentPosition].y);
    
    for (SSKWaterJoint *joint in joints) {
        CGPathAddLineToPoint(path, nil, [joint currentPosition].x, [joint currentPosition].y);
    }
    CGPathCloseSubpath(path);
    return path;
}

#pragma mark - Apply splash 
- (void)splash:(NSUInteger)index speed:(CGFloat)speed {
    if (index < self.waterJoints.count) {
        [(SSKWaterJoint*)[self.waterJoints objectAtIndex:index] setSpeed:speed];
    }
}

#pragma mark - Update
- (void)update:(NSTimeInterval)dt {
    [self updateJoints:dt];
    [self updateSurfaceNodes:dt];
}

- (void)updateJoints:(NSTimeInterval)dt {
    //Apply Hooke's law
    for (int i = 0; i < self.waterJoints.count; i++) {
        [(SSKWaterJoint*)[self.waterJoints objectAtIndex:i] update:dt];
    }
    
    NSMutableArray *leftDeltas = [self arrayWithCapacity:self.waterJoints.count];
    NSMutableArray *rightDeltas = [self arrayWithCapacity:self.waterJoints.count];
    
    for (int j = 0; j < 8; j ++) {
        for (int i = 0; i < self.waterJoints.count; i++) {
            SSKWaterJoint *currentJoint = (SSKWaterJoint*)[self.waterJoints objectAtIndex:i];
            if (i > 0) {
                SSKWaterJoint *previousjoint = (SSKWaterJoint*)[self.waterJoints objectAtIndex:i - 1];
                [leftDeltas removeObjectAtIndex:i];
                [leftDeltas insertObject:[NSNumber numberWithFloat:(self.spread * (currentJoint.currentPosition.y - previousjoint.currentPosition.y))] atIndex:i];
                [self newSpeed:[(NSNumber*)[leftDeltas objectAtIndex:i] floatValue] waterJointAtIndex:i - 1];
            }
            if (i < self.waterJoints.count - 1) {
                SSKWaterJoint *nextJoint = (SSKWaterJoint*)[self.waterJoints objectAtIndex:i + 1];
                [rightDeltas removeObjectAtIndex:i];
                [rightDeltas insertObject:[NSNumber numberWithFloat:(self.spread * (currentJoint.currentPosition.y - nextJoint.currentPosition.y))] atIndex:i];
                [self newSpeed:[(NSNumber*)[rightDeltas objectAtIndex:i] floatValue] waterJointAtIndex:i + 1];
            }
        }
        for (int i = 0; i < self.waterJoints.count; i++) {
            if (i > 0) {
                [self newHeight:[(NSNumber*)[leftDeltas objectAtIndex:i] floatValue] waterJointAtIndex:i - 1];
            }
            if (i < self.waterJoints.count - 1) {
                [self newHeight:[(NSNumber*)[rightDeltas objectAtIndex:i] floatValue] waterJointAtIndex:i + 1];
            }
        }
    }
}

- (void)updateSurfaceNodes:(NSTimeInterval)dt {
    [self.waterSurface setPath:[self pathFromJoints:self.waterJoints]];
}

#pragma mark - Convenience
- (void)newHeight:(CGFloat)delta waterJointAtIndex:(NSUInteger)index {
    CGPoint oldPosition = [(SSKWaterJoint*)[self.waterJoints objectAtIndex:index] currentPosition];
    CGFloat newHeight = oldPosition.y + delta;
    
    [(SSKWaterJoint*)[self.waterJoints objectAtIndex:index] setCurrentPosition:CGPointMake(oldPosition.x, newHeight)];
}

- (void)newSpeed:(CGFloat)delta waterJointAtIndex:(NSUInteger)index {
    CGFloat oldSpeed = [(SSKWaterJoint*)[self.waterJoints objectAtIndex:index] speed];
    CGFloat newSpeed = oldSpeed + delta;

    NSLog(@"new speed: %fl",newSpeed);
    
    [(SSKWaterJoint*)[self.waterJoints objectAtIndex:index] setSpeed:newSpeed];
}

- (NSMutableArray*)arrayWithCapacity:(NSUInteger)capacity {
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < capacity; i++) {
        [array addObject:[NSNumber numberWithFloat:0]];
    }
    return array;
}
@end
