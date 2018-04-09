# Apple Watch + SpriteKit: Example Project 

This is a sample project to shown how to use SpriteKit for animations on 
the Apple Watch. 
See the [full explanation on Medium](https://medium.com/@eriadam/animations-on-apple-watch-with-spritekit-665b981e7b64).

**1. Watch Extension: InterfaceController**

Create an IBOutlet for the SpriteKit scene. It has to be of type 
WKInterfaceSKScene. 

**2. Watch: Assets**

Add the different resolutions of the heart image to your Assets folder.

**3. Watch Extension: SpriteKit Scene**

Add a new SpriteKit scene to the extension target. Add an SKSpriteNode to the 
scene and set the texture to the heart image.

**4. SpriteKit Scene: Animations**

For the animation we added scaleTo actions to the sprite node. One for 
enlarging, one for shrinking, then a pause, with a total duration of 1 second. 
Then an infinite loop is created from these actions.

**5. Watch: Interface.storyboard**

Add a SpriteKit scene to the storyboard and connect it to the IBOutlet. 
Set the scene property to the one you created above. Make sure the isPaused 
property is not checked, so the animation is started as soon the scene appears 
on the screen.
