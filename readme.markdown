#Dice

Created by Leonhard Lichtschlag (leonhard@lichtschlag.net) on 02/May/13.

Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.

---

### What you'll find in this source

DiceMobile marries the falling cubes project from the Bullet physics library to OpenGL ES 2.
I started this project to learn about OpenGL ES 2.0, and shared it on github.
For the WWDC Demo, I added the animations for the objects so that I only have to provide start and end states and the in between is computed automatically (as with many CAAnimations).
Of course, the textures were completely different before and the tumbling dice was the only state.
The motions of the device are filtered so that sudden movements trigger impulses on the dice, but normal gravity does not.

DiceTextureGenerator is a small helper to convert images into 16 textures for the dice.

For the public release on Github, I removed all private information, leaving the placeholder textures.

---

### Known Issues & Future Work

1.	The Leaks tool reports lost memory on behalf of GLKBasicEffect. I cannot figure out how this is not a bug in the framework.
2.	If the view were to unload, the motion states would probably leak, too. Then again, our view never unloads.
3.	There is way to much functionality in one class, at the very least the button code should go into into its own class and the animatitions as well.
4.	Speaking of animations, if I had more time, I would have refactored it as block based syntax, so that all logic code how the animations are chained is at the point of the IBAction, i.e.:

		- (void) userDidSwipeRight
		{
			[self.diceAnimator splitWithCompletionBlock:^
			{
				[self.diceAnimator rotateLeftWithCompletionBlock:^
				{
					[self.diceAnimator mergeWithCompletionBlock:nil];
				}];
			}];
		}
	
5.	Of course, a proper iPad app should run on landscape mode and the only reason I disabled the iPhone target for now is that I could not find the time to adapt to iPhone 5 screens.


