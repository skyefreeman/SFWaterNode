//
//  SFWaterNode.m
//  SFWaterNode
//
//  Created by Skye on 3/1/15.
//  Copyright (c) 2015 Skye Freeman. All rights reserved.
//

#import "SFWaterNode.h"

CGFloat const kDefaultSpread = 0.15;
CGFloat const kDefaultJointWidth = 10.0;
CGFloat const kDefaultDamping = 0.04;
CGFloat const kDefaultTension = 0.03;

@implementation SFWaterJoint

+ (instancetype)jointWithPosition:(CGPoint)position {
    return [[self alloc] initWithPosition:position];
}

- (instancetype)initWithPosition:(CGPoint)position {
    self = [super init];
    if (self) {
        self.startPosition = position;
        self.currentPosition = position;
        self.speed = 0;
        self.damping = kDefaultDamping;
        self.tension = kDefaultTension;
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

@interface SFWaterNode()

@property (nonatomic, copy) NSMutableArray *waterJoints;
@property (nonatomic) SKShapeNode *waterSurface;
@property (nonatomic) CGFloat spread;
@property (nonatomic, readwrite) CGFloat jointWidth;
@end

@implementation SFWaterNode(Convenience)

- (CGFloat)maxX {
    return [(SFWaterJoint *)self.waterJoints.lastObject startPosition].x;
}

- (CGFloat)minX {
    return [(SFWaterJoint *)self.waterJoints.firstObject startPosition].x;
}

- (BOOL)hasDepth {
    return self.bodyDepth > 0;
}

@end

@implementation SFWaterNode {
    CGPathRef _waterPath;
}

#pragma mark - Initialize with body texture

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                           texture:(SKTexture*)texture
{
    self = [super init];
    if (self) {
        
        self.spread = kDefaultSpread;
        self.jointWidth = kDefaultJointWidth;
        self.bodyDepth = depth;
        self.waterJoints = [self createSurfacePointsWithStart:startPoint end:endPoint];
        
        _waterPath = [self newPathFromJoints:self.waterJoints];
        self.waterSurface = [SKShapeNode shapeNodeWithPath:_waterPath];
        self.waterSurface.strokeColor = (depth > 0) ? [SKColor clearColor] : [SKColor whiteColor];
        [self addChild:self.waterSurface];
        
        if (texture != nil) {
            [self setTexture:texture];
        }
    }
    return self;
}

+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                           texture:(SKTexture*)texture
{
    return [[self alloc] initWithStartPoint:startPoint
                                   endPoint:endPoint
                                      depth:depth
                                    texture:texture];
}

#pragma mark - Initialize with body color

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                             color:(SKColor*)color
{
    self = [self initWithStartPoint:startPoint
                           endPoint:endPoint
                              depth:depth
                            texture:nil];

    if (self) {
        [self.waterSurface setFillColor:color];
    }
    return self;
}

+ (instancetype)nodeWithStartPoint:(CGPoint)startPoint
                          endPoint:(CGPoint)endPoint
                             depth:(CGFloat)depth
                             color:(SKColor*)color
{
    return [[self alloc] initWithStartPoint:startPoint
                                   endPoint:endPoint
                                      depth:depth
                                      color:color];
}

#pragma mark - Water joint creation

- (NSMutableArray*)createSurfacePointsWithStart:(CGPoint)startPoint end:(CGPoint)endPoint {
    NSMutableArray *tempPoints = [NSMutableArray new];
    [tempPoints addObject:[SFWaterJoint jointWithPosition:startPoint]];
    
    //Get distance between points
    double distance = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2));
    
    //Get angle between start and end
    double rads = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);

    CGFloat totalWidth = 0;
    for (int i = 1; totalWidth < distance; i++) {
        totalWidth += self.jointWidth;
        
        double nextX = startPoint.x + totalWidth * cos(rads);
        double nextY = startPoint.y + totalWidth * sin(rads);
        [tempPoints insertObject:[SFWaterJoint jointWithPosition:CGPointMake(nextX, nextY)] atIndex:i];
    }

    return [NSMutableArray arrayWithArray:tempPoints];
}

- (CGPathRef)newPathFromJoints:(NSArray*)joints {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, [(SFWaterJoint*)[joints objectAtIndex:0] currentPosition].x,[(SFWaterJoint*)[joints objectAtIndex:0] currentPosition].y);
    
    for (SFWaterJoint *joint in joints) {
        CGPathAddLineToPoint(path, nil, [joint currentPosition].x, [joint currentPosition].y);
    }
    
    if ([self hasDepth]) {
        SFWaterJoint *firstJoint = (SFWaterJoint*)[joints firstObject];;
        SFWaterJoint *lastJoint = (SFWaterJoint*)[joints lastObject];
        
        CGPathAddLineToPoint(path, nil, lastJoint.currentPosition.x, lastJoint.currentPosition.y - self.bodyDepth - (lastJoint.currentPosition.y - lastJoint.startPosition.y));
        CGPathAddLineToPoint(path, nil, firstJoint.currentPosition.x, firstJoint.currentPosition.y - self.bodyDepth - (firstJoint.currentPosition.y - firstJoint.startPosition.y));
        CGPathCloseSubpath(path);
    }
    return path;
}

#pragma mark - Apply splash

- (void)splash:(CGPoint)location
         speed:(CGFloat)speed
{
    SFWaterJoint *joint = [self jointAtXPosition:location.x];
    [joint setSpeed:speed];
}

- (SFWaterJoint *)jointAtXPosition:(CGFloat)xLocation {
    if (xLocation >= self.maxX) return self.waterJoints.lastObject;
    else if (xLocation <= self.minX) return self.waterJoints.firstObject;
    
    CGFloat distance = self.maxX - self.minX;
    CGFloat offsetXLocation = xLocation - self.minX;
    CGFloat percentageXLocation = offsetXLocation/distance;
    return self.waterJoints[(NSInteger)(self.waterJoints.count * percentageXLocation)];
}

#pragma mark - Update

- (void)update:(NSTimeInterval)dt {
    [self updateJoints:dt];
    [self updateSurfaceNodes:dt];
}

- (void)updateJoints:(NSTimeInterval)dt {
    // Apply Hooke's Law!
    for (SFWaterJoint *joint in self.waterJoints) {
        [joint update:dt];
    }
    
    NSMutableArray *leftDeltas = [self placeholderArrayWithCapacity:self.waterJoints.count];
    NSMutableArray *rightDeltas = [self placeholderArrayWithCapacity:self.waterJoints.count];
    NSUInteger iterations = 1;
    
    for (int j = 0; j < iterations; j++) {
        
        // Set the updated joint speed.
        for (int i = 0; i < self.waterJoints.count; i++) {
            if (i > 0) {
                [self updateJointSpeedsWithDeltas:leftDeltas right:NO index:i];
            }
            if (i < self.waterJoints.count - 1) {
                [self updateJointSpeedsWithDeltas:rightDeltas right:YES index:i];
            }
        }
        
        // Set the updated joint height in a separate iteration.
        for (int i = 0; i < self.waterJoints.count; i++) {
            if (i > 0) {
                [self updateJointHeightsWithDeltas:leftDeltas right:NO index:i];
            }
            if (i < self.waterJoints.count - 1) {
                [self updateJointHeightsWithDeltas:rightDeltas right:YES index:i];
            }
        }
    }
}

- (void)updateJointSpeedsWithDeltas:(NSMutableArray *)jointDeltas
                             right:(BOOL)rightwards
                             index:(NSInteger)index
{
    NSInteger offset = rightwards ? 1 : -1;
    SFWaterJoint *currentJoint = [self.waterJoints objectAtIndex:index];
    SFWaterJoint *nextJoint = [self.waterJoints objectAtIndex:index + offset];
    CGFloat delta = self.spread * (currentJoint.currentPosition.y - nextJoint.currentPosition.y);
    
    [jointDeltas replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:delta]];
    
    CGFloat oldSpeed = nextJoint.speed;
    nextJoint.speed = oldSpeed + delta;
}

- (void)updateJointHeightsWithDeltas:(NSMutableArray *)jointDeltas
                              right:(BOOL)rightwards
                              index:(NSInteger)index
{
    NSInteger offset = rightwards ? 1 : -1;
    CGFloat delta = [(NSNumber *)jointDeltas[index] floatValue];
    
    SFWaterJoint *nextJoint = (SFWaterJoint*)self.waterJoints[index + offset];
    CGPoint oldPosition = nextJoint.currentPosition;
    CGFloat newHeight = oldPosition.y + delta;
    nextJoint.currentPosition = CGPointMake(oldPosition.x, newHeight);
}

- (void)updateSurfaceNodes:(NSTimeInterval)dt {
    CGPathRelease(_waterPath);
    _waterPath = [self newPathFromJoints:self.waterJoints];
    
    [self.waterSurface setPath:_waterPath];
}

#pragma mark - Setting a texture to the body

- (void)setTexture:(SKTexture*)texture {
    NSAssert([self hasDepth], @"Cannot set a texture to a body without depth.");
    
    [self.waterSurface setFillColor:[SKColor whiteColor]];
    [self.waterSurface setFillTexture:texture];
}

#pragma mark - Changing SFWaterJoint Properties

- (void)setSplashDamping:(CGFloat)damping {
    for (SFWaterJoint *joint in self.waterJoints) {
        joint.damping = damping;
    }
}

- (void)setSplashTension:(CGFloat)tension {
    for (SFWaterJoint *joint in self.waterJoints) {
        joint.tension = tension;
    }
}

#pragma mark - Convenience

- (NSMutableArray*)placeholderArrayWithCapacity:(NSUInteger)capacity {
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < capacity; i++) {
        [array addObject:[NSNumber numberWithFloat:0]];
    }
    return array;
}

@end
