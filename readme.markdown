#Dice

Created by Leonhard Lichtschlag (leonhard@lichtschlag.net) on 29/Feb/12.  
Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.

---

Dice marries the falling cubes project from the Bullet physics library to OpenGL ES 2.

---

### Known Issues

1)	The Leaks tool reports lost memory on behalf of GLKBasicEffect. I cannot figure 
	out how this is not a bug in the framework.
2)	If the View were to unload, the motion states would probably leak, too.
