//
//  L2RAppDelegate.m
//  DiceTextureGenerator
//
//  Created by Leonhard Lichtschlag on 01/May/13.
//  Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.
//

#import "L2RAppDelegate.h"

@implementation L2RAppDelegate

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (IBAction)userDidPressStartButton:(id)sender
{
	NSString *pathToContainingFolder = [@"~/Desktop/textures/" stringByExpandingTildeInPath];

	// images are 2048 * 2048, each tile is 512 * 512
	NSImage *frontImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.001.jpg"]];
	NSImage *backImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.002.jpg"]];
	NSImage *rightImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.003.jpg"]];
	NSImage *leftImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.004.jpg"]];
	NSImage *topImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.005.jpg"]];
	NSImage *bottomImage = [[NSImage alloc] initWithContentsOfFile:[pathToContainingFolder stringByAppendingPathComponent:@"face.006.jpg"]];

	NSInteger stride = 512;
	
	NSMutableArray *textureArray = [NSMutableArray array];
	
	// piece each texture together from the six complete images
	for (int iteratorY = 0 ; iteratorY < 4; iteratorY++)
	{
		for (int iteratorX = 0 ; iteratorX < 4; iteratorX++)
		{
			// texture files are 1024 * 1536
			NSImage *texture = [NSImage imageWithSize:CGSizeMake(2 * stride, 3 * stride) flipped:NO drawingHandler:^BOOL(NSRect dstRect)
			{
				// nsimage coordinate system start in the bottom right
				[frontImage drawAtPoint:NSMakePoint(0, 2*stride)
							   fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							  operation:NSCompositeSourceOver
							   fraction:1.0];
				[backImage drawAtPoint:NSMakePoint(stride, 2*stride)
							  fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							 operation:NSCompositeSourceOver
							  fraction:1.0];
				[leftImage drawAtPoint:NSMakePoint(0, stride)
							  fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							 operation:NSCompositeSourceOver
							  fraction:1.0];
				[bottomImage drawAtPoint:NSMakePoint(stride, stride)
								fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							   operation:NSCompositeSourceOver
								fraction:1.0];
				[rightImage drawAtPoint:NSMakePoint(0, 0)
							   fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							  operation:NSCompositeSourceOver
							   fraction:1.0];
				[topImage drawAtPoint:NSMakePoint(stride, 0)
							 fromRect:NSMakeRect(stride * iteratorX, stride * iteratorY, stride, stride)
							operation:NSCompositeSourceOver
							 fraction:1.0];
				return YES;
			}];
			
			// store texture
			[textureArray addObject:texture];
		}
	}
	
	// write textures out into files
	for (int i = 0 ; i < 16; i++)
	{
		NSImage *texture = textureArray[i];
		NSString *fileName = [[NSString  alloc] initWithFormat:@"texture.%d.jpg", i];
		NSString *filePath = [pathToContainingFolder stringByAppendingPathComponent:fileName];

		// the image is not drawn yet and we need to force a bitmap representation before cocoa can build jpegs
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[texture TIFFRepresentation]];
		NSData *bitmapData = [imageRep representationUsingType:NSJPEGFileType properties:@{ NSImageCompressionFactor:@(1.1) }];

		[bitmapData writeToFile:filePath atomically:YES];
	}
}


@end
