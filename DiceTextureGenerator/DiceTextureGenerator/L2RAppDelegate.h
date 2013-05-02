//
//  L2RAppDelegate.h
//  DiceTextureGenerator
//
//  Created by Leonhard Lichtschlag on 01/May/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface L2RAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction) userDidPressStartButton:(id)sender;

@end
