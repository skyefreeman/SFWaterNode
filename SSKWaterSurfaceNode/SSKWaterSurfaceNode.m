//
//  SSKWaterSurfaceNode.m
//  SSKWaterSurfaceNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "SSKWaterSurfaceNode.h"

CGFloat const kDefaultSpread = 0.15;
CGFloat const kDefaultJointWidth = 10.0;

@implementation SSKWaterJoint
+ (instancetype)jointWithPosition:(CGPoint)position {
    return [[self alloc] initWithPosition:position];
}

- (instancetype)initWithPosition:(CGPoint)position {
    self = [super init];
    if (self) {
        self.startPosition = position;
        self.currentPosition = position;
        self.speed = 0;
        
        self.damping = 0.04;
        self.tension = 0.03;
    }
    return self;
}

- (void)update:(NSTimeInterval)dt {
    CGFloat x = self.currentPosition.y - self.startPosition.y;
    CGFloat acceleration = (-self.tension * x) - (self.speed * self.damping);
    
    self.currentPosition = CGPointMake(self.currentPosition.x, self.currentPosition.y + self.speed);
    self.speed += acceleration;
}

@end

@interface SSKWaterSurfaceNode()
@property (nonatomic) NSMutableArray *waterJoints;
@property (nonatomic) SKShapeNode *waterSurface;
@property (nonatomic, readwrite) CGFloat jointWidth;
@property (nonatomic) CGFloat spread;

@property (nonatomic) BOOL hasDepth;
@property (nonatomic) CGFloat bodyDepth;
@end

@implementation SSKWaterSurfaceNode

#pragma mark - Initialize with body texture
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth texture:(SKTexture*)texture {
    self = [super init];
    if (self) {
        self.spread = kDefaultSpread;
        
        if (jointWidth) {
            self.jointWidth = jointWidth;
        }
        
        self.waterJoints = [self createSurfacePointsWithStart:startPoint end:endPoint];
        
        self.waterSurface = [SKShapeNode shapeNodeWithPath:[self pathFromJoints:self.waterJoints]];
        [self.waterSurface setStrokeColor:[UIColor clearColor]];
        [self addChild:self.waterSurface];
        
        if (depth > 0) {
            [self setBodyWithDepth:depth];
        }
        
        if (texture) {
            [self setTexture:texture];
        }
    }
    
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth texture:(SKTexture *)texture {
    return [self initWithStartPoint:startPoint endPoint:endPoint jointWidth:kDefaultJointWidth depth:depth texture:texture];
}

#pragma mark - Initialize with body color
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth color:(SKColor*)color {
    self = [self initWithStartPoint:startPoint endPoint:endPoint jointWidth:jointWidth depth:depth texture:nil];
    if (self) {
        if (color) {
            if (depth > 0) {
                [self.waterSurface setFillColor:color];
            }
        }
    }
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth color:(SKColor*)color {
    return [self initWithStartPoint:startPoint endPoint:endPoint jointWidth:kDefaultJointWidth depth:depth color:color];
}

#pragma mark - Initialize with surface path
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth {
    return [self initWithStartPoint:startPoint endPoint:endPoint jointWidth:jointWidth depth:0 texture:nil];
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    return [self initWithStartPoint:startPoint endPoint:endPoint jointWidth:kDefaultJointWidth];
}

#pragma mark - Convenience Initializers
//Texture init
+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth texture:(SKTexture*)texture {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint jointWidth:jointWidth depth:depth texture:texture];
}

+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth texture:(SKTexture *)texture {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint depth:depth texture:texture];
}

//Color init
+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth depth:(CGFloat)depth color:(SKColor*)color {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint jointWidth:jointWidth depth:depth color:color];
}

+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint depth:(CGFloat)depth color:(SKColor*)color {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint depth:depth color:color];
}

//Surface only init
+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint jointWidth:(CGFloat)jointWidth {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint jointWidth:jointWidth];
}

+ (instancetype)surfaceWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    return [[self alloc] initWithStartPoint:startPoint endPoint:endPoint];
}

#pragma mark - Water joint creation
- (NSMutableArray*)createSurfacePointsWithStart:(CGPoint)startPoint end:(CGPoint)endPoint {
    NSMutableArray *tempPoints = [NSMutableArray new];
    [tempPoints addObject:[SSKWaterJoint jointWithPosition:startPoint]];
    
    //Get distance between points
    double distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2));
    
    //Get angle between start and end
    double rads = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);

    CGFloat totalWidth = 0;
    for (int i = 1; totalWidth < distance; i++) {
        totalWidth += self.jointWidth;
        
        double nextX = startPoint.x + totalWidth * cos(rads);
        double nextY = startPoint.y + totalWidth * sin(rads);
        [tempPoints insertObject:[SSKWaterJoint jointWithPosition:CGPointMake(nextX, nextY)] atIndex:i];
    }

    return [NSMutableArray arrayWithArray:tempPoints];
}

- (CGPathRef)pathFromJoints:(NSArray*)joints {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, [(SSKWaterJoint*)[joints objectAtIndex:0] currentPosition].x,[(SSKWaterJoint*)[joints objectAtIndex:0] currentPosition].y);
    
    for (SSKWaterJoint *joint in joints) {
        CGPathAddLineToPoint(path, nil, [joint currentPosition].x, [joint currentPosition].y);
    }
    
    //Only if surface has a body
    if (self.hasDepth) {
        SSKWaterJoint *firstJoint = (SSKWaterJoint*)[joints firstObject];;
        SSKWaterJoint *lastJoint = (SSKWaterJoint*)[joints lastObject];
        
        CGPathAddLineToPoint(path, nil, lastJoint.currentPosition.x, lastJoint.currentPosition.y - self.bodyDepth - (lastJoint.currentPosition.y - lastJoint.startPosition.y));
        CGPathAddLineToPoint(path, nil, firstJoint.currentPosition.x, firstJoint.currentPosition.y - self.bodyDepth - (firstJoint.currentPosition.y - firstJoint.startPosition.y));
        CGPathCloseSubpath(path);
    }
    return path;
}

#pragma mark - Apply splash
- (void)splash:(CGPoint)location speed:(CGFloat)speed {
    //Find the closest joint to given location
    int closestJointIndex = 0;
    CGFloat shortestDistance = CGFLOAT_MAX;
    for (int i = 0; i < self.waterJoints.count; i++) {
        SSKWaterJoint *joint = (SSKWaterJoint*)[self.waterJoints objectAtIndex:i];
        CGFloat distance = fabsf(joint.currentPosition.x - location.x);
        
        if (distance < shortestDistance) {
            shortestDistance = distance;
            closestJointIndex = i;
        }
    }
    [(SSKWaterJoint*)[self.waterJoints objectAtIndex:closestJointIndex] setSpeed:speed];
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
    NSUInteger iterations = 1;
    
    for (int j = 0; j < iterations; j ++) {
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
    [self.waterSurface setPath:nil];
    [self.waterSurface setPath:[self pathFromJoints:self.waterJoints]];
}

#pragma mark - Setting a texture to the body
- (void)setTexture:(SKTexture*)texture {
    if (self.hasDepth) {
        [self.waterSurface setFillColor:[SKColor whiteColor]];
        [self.waterSurface setFillTexture:texture];
    }
}

#pragma mark - Setting a body to the water surface
- (void)setBodyWithDepth:(CGFloat)depth {
    self.hasDepth = YES;
    self.bodyDepth = depth;
}

#pragma mark - Changing SSKWaterJoint Properties
- (void)setSplashDamping:(CGFloat)damping {
    for (SSKWaterJoint *joint in self.waterJoints) {
        joint.damping = damping;
    }
}

- (void)setSplashTension:(CGFloat)tension {
    for (SSKWaterJoint *joint in self.waterJoints) {
        joint.tension = tension;
    }
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
