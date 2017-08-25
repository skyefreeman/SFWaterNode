//
//  SFViewController.m
//  SFWaterNode
//
//  Created by skyefreeman on 08/25/2017.
//  Copyright (c) 2017 skyefreeman. All rights reserved.
//

#import "SFViewController.h"
#import "SFGameScene.h"

@interface SFViewController ()
@end

@implementation SFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.ignoresSiblingOrder = YES;

    SFGameScene *scene = [SFGameScene sceneWithSize:skView.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
