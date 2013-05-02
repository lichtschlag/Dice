#Dice

Created by Leonhard Lichtschlag (leonhard@lichtschlag.net) on 02/May/13.
Copyright (c) 2013 Leonhard Lichtschlag. All rights reserved.

---

### What you'll find in this source

DiceMobile marries the falling cubes project from the Bullet physics library to OpenGL ES 2.
DiceTExtureGenerator is a small helper to convert images into 16 textures for the dice.


---

### Known Issues

1)	The Leaks tool reports lost memory on behalf of GLKBasicEffect. I cannot figure 
	out how this is not a bug in the framework.
2)	If the view were to unload, the motion states would probably leak, too. THen again, 
	our view never unloads.


