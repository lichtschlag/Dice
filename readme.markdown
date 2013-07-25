#Dice

Created by Leonhard Lichtschlag (leonhard@lichtschlag.net) on 29/Feb/12.  
Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.

---

Dice marries the falling cubes project from the Bullet physics library to OpenGL ES 2.
The Dice image was created by Deeo-Elaxclaire (http://deeo-elaclaire.deviantart.com/art/Dice-194725312). 
Used with permission.

Check the other branch for the WWDC 2013 Student Scholarship Entry that emerged from this project.

---

### Known Issues

1.	The Leaks tool reports lost memory on behalf of GLKBasicEffect. I cannot figure 
	out how this is not a bug in the framework.
2.	If the view were to unload, the motion states would probably leak, too.
