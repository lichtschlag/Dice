//
//  DMViewController.m
//  DiceMobile
//
//  Created by Leonhard Lichtschlag on 24/Feb/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "DMViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "btBulletDynamicsCommon.h"


#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[6*6*8] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,		tex0.x, tex0.y
    1.0f,-1.0f,-1.0f,			1.0f, 0.0f, 0.0f,			0.0f, 0.0f,
    1.0f, 1.0f,-1.0f,         1.0f, 0.0f, 0.0f,			0.5f, 0.0f,
    1.0f,-1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.0f, 0.33f,
    1.0f,-1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.0f, 0.33f,
    1.0f, 1.0f,-1.0f,         1.0f, 0.0f, 0.0f,			0.5f, 0.0f,
    1.0f, 1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.5f, 0.33f,
    
     1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			0.5f, 0.0f,
    -1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			1.0f, 0.0f,
     1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			0.5f, 0.33f,
     1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			0.5f, 0.33f,
    -1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			1.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			1.0f, 0.33f,
    
    -1.0f, 1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,			0.0f, 0.33f,
    -1.0f,-1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,			0.5f, 0.33f,
    -1.0f, 1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,			0.0f, 0.66f,
    -1.0f, 1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,			0.0f, 0.66f,
    -1.0f,-1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,			0.5f, 0.33f,
    -1.0f,-1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,			0.5f, 0.66f,
    
    -1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,			0.5f, 0.33f,
     1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,			1.0f, 0.33f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,			0.5f, 0.66f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,			0.5f, 0.66f,
     1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,			1.0f, 0.33f,
     1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,			1.0f, 0.66f,
    
     1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.0f, 0.66f,
    -1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.5f, 0.66f,
     1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.0f, 1.0f,
     1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.5f, 0.66f,
    -1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,			0.5f, 1.0f,
    
	 1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			0.5f, 0.66f,
	-1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			1.0f, 0.66f,
	 1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			0.5f, 1.0f,
	 1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			0.5f, 1.0f,
	-1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			1.0f, 0.66f,
	-1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,			1.0f, 1.0
};


// ===============================================================================================================
@interface DMViewController () 
// ===============================================================================================================
{
	GLuint mVertexBuffer;
	GLuint mDiceVertexArray;
	
	// Physics
	btDiscreteDynamicsWorld					*pDynamicsWorld;
	
	btBroadphaseInterface						*pBroadphase;
	btCollisionConfiguration					*pCollisionConfig;
	btCollisionDispatcher						*pCollisionDispatcher;
	btSequentialImpulseConstraintSolver		*pConstraintSolver;
	
	btAlignedObjectArray<btRigidBody*>			*pBoxBodies;
	btAlignedObjectArray<btRigidBody*>			*pWorldPlanes;
	btAlignedObjectArray<btCollisionShape*>	*pCollisionShapes;
	
	// motion filtering
	double gravity[3];
	BOOL firstAccelerometerData;
}

@property (strong, nonatomic) EAGLContext *context;
//@property (strong, nonatomic) GLKReflectionMapEffect *objectEffect;
@property (strong, nonatomic) GLKBaseEffect *objectEffect;
@property (strong, nonatomic) GLKSkyboxEffect *environmentEffect;
@property int diceNumber;
@property (strong) CMMotionManager *motionManager;

- (void) setupGL;
- (void) setupScene;
- (void) setupBullet;

- (void) tearDownGL;
- (void) tearDownScene;
- (void) tearDownBullet;

@end


// ===============================================================================================================
@implementation DMViewController
// ===============================================================================================================

@synthesize context			= mContext;
@synthesize objectEffect		= mObjectEffect;
@synthesize environmentEffect	= mEnvironmentEffect;
@synthesize diceNumber			= mDiceNumber;
@synthesize motionManager		= mMotionManager;


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.diceNumber = 12;
	
	[self setupGL];
	[self setupBullet];
	[self setupScene];
	
	self.motionManager = [[CMMotionManager alloc] init]; // motionManager is an instance variable
	self.motionManager.accelerometerUpdateInterval = 0.16; // 60Hz
	[self.motionManager startAccelerometerUpdates];
	memset(gravity, 0, sizeof(gravity));
	firstAccelerometerData = YES;
}


- (void) viewDidUnload
{    
	[super viewDidUnload];
    
	[self.motionManager stopAccelerometerUpdates];
	self.motionManager = nil;
	
	[self tearDownGL];
	[self tearDownBullet];    
	[self tearDownScene];
}


- (void) setupGL
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) 
        NSLog(@"Failed to create GL ES 2.0 context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;

	[EAGLContext setCurrentContext:self.context];
	glEnable(GL_DEPTH_TEST);
}


- (void) setupScene
{
	[EAGLContext setCurrentContext:self.context];
	
	// load texture data
	NSError *outError = nil;
	NSURL *textureURL				= [[NSBundle mainBundle] URLForResource:@"DiceSides" withExtension:@"jpg"];
	NSDictionary *options			= [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithBool:NO],  GLKTextureLoaderGenerateMipmaps,
									   [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
	GLKTextureInfo *textureInfo	= [GLKTextureLoader textureWithContentsOfURL:textureURL options:options error:&outError];
	
	textureURL						= [[NSBundle mainBundle] URLForResource:@"EnvironmentCubeMap" withExtension:@"jpg"];
	options							= [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithBool:NO],  GLKTextureLoaderGenerateMipmaps,
									   nil];
	GLKTextureInfo *cubeMapInfo	= [GLKTextureLoader cubeMapWithContentsOfURL:textureURL options:options error:&outError];
	
	if (!textureInfo)
		NSLog(@"%s %@", __PRETTY_FUNCTION__, outError);
	
	// load mesh for one dice to graphics card
	glGenVertexArraysOES(1, &mDiceVertexArray);
	glBindVertexArrayOES(mDiceVertexArray);
	
    glGenBuffers(1, &mVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, mVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GLfloat), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8*sizeof(GLfloat), BUFFER_OFFSET(3*sizeof(GLfloat)));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8*sizeof(GLfloat), BUFFER_OFFSET(6*sizeof(GLfloat)));
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArrayOES(0);

	// create a simple effect for the dice
//	self.objectEffect = [[GLKReflectionMapEffect alloc] init];
	self.objectEffect = [[GLKBaseEffect alloc] init];
	self.objectEffect.light0.enabled			= GL_TRUE;
	self.objectEffect.light0.diffuseColor		= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.objectEffect.texture2d0.enabled		= GL_TRUE;
	self.objectEffect.texture2d0.name			= textureInfo.name;
	self.objectEffect.useConstantColor			= GL_TRUE;
	self.objectEffect.constantColor				= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.objectEffect.lightingType				= GLKLightingTypePerPixel;
//	self.objectEffect.textureCubeMap.name		= cubeMapInfo.name;
//	self.objectEffect.textureCubeMap.envMode	= GLKTextureEnvModeModulate;

	// compute projection matix
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f),	// FoV
															aspect,									// Sceen aspect
															0.1f, 100.0f);							// Near/far plane
    self.objectEffect.transform.projectionMatrix = projectionMatrix;
	
	// create skybox effect
	self.environmentEffect = [[GLKSkyboxEffect alloc] init]; 
	self.environmentEffect.transform.projectionMatrix = projectionMatrix;
	self.environmentEffect.textureCubeMap.name = cubeMapInfo.name;
	self.environmentEffect.xSize = 100.0f;
	self.environmentEffect.ySize = 100.0f;
	self.environmentEffect.zSize = 100.0f;
	
	// -----------------------------------------------------------------------------------------------------------
	pDynamicsWorld->setGravity( btVector3(0, -10 ,0) );
	
	// create 6 planes / half spaces (world contraints)
	pWorldPlanes = new btAlignedObjectArray<btRigidBody*>();
	pCollisionShapes = new btAlignedObjectArray<btCollisionShape*>();
	btBoxShape* worldBoxShape = new btBoxShape( btVector3(10, 10, 10) );		// world constraints
	for (int i = 0; i < 6; i++)
	{
		btVector4 planeEq;
		worldBoxShape->getPlaneEquation(planeEq, i);				// get the i-th side of world box
		btCollisionShape* worldBoxSideShape = new btStaticPlaneShape(-planeEq, planeEq[3]);
		
		btScalar mass = 0.0f;		// rigidbody is dynamic if and only if mass is non zero, otherwise static
		btVector3 localInertia(0, 0, 0);
		
		btTransform groundTransform;
		groundTransform.setIdentity();
		groundTransform.setOrigin( btVector3(0, 0, 0) );			// origin == translation
		
		btDefaultMotionState* myMotionState = new btDefaultMotionState(groundTransform);
		btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, myMotionState, worldBoxSideShape, localInertia);
		rbInfo.m_restitution	= 0.9;

		btRigidBody* sFloorPlaneBody = new btRigidBody(rbInfo);
		pWorldPlanes->push_back(sFloorPlaneBody);
		pCollisionShapes->push_back(worldBoxSideShape);
		
		// add the body to the dynamics world
		pDynamicsWorld->addRigidBody(sFloorPlaneBody);
	}
	delete worldBoxShape;
	worldBoxShape = NULL;
	
	// create the some boxes
	pBoxBodies = new btAlignedObjectArray<btRigidBody*>();

	// create collision shape that all dice share
	btCollisionShape* boxShape = new btBoxShape( btVector3(1, 1, 1) );	
	btScalar mass = 0.20;		// positive mass means dynamic/moving object
	btVector3 localInertia(0, 0, 0);
	boxShape->calculateLocalInertia(mass, localInertia);
	pCollisionShapes->push_back(boxShape);

	for (int i = 0; i < self.diceNumber; i++)
	{
		btTransform objectTransform;
		objectTransform.setIdentity();
		float stride = 3.0;
		div_t division = div(i, 3);
		objectTransform.setOrigin( btVector3(division.rem * stride, division.quot * stride, 0) );

		btDefaultMotionState* myMotionState = new btDefaultMotionState(objectTransform);
		btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, myMotionState, boxShape, localInertia);
		rbInfo.m_restitution	= 1.0;

		btRigidBody* boxBody	= new btRigidBody(rbInfo);
		pBoxBodies->push_back(boxBody);
		
		// most applications shouldn't disable deactivation, but for this demo it is better.
		boxBody->setActivationState(DISABLE_DEACTIVATION);
		// add the body to the dynamics world
		pDynamicsWorld->addRigidBody(boxBody);
	}
}


- (void) setupBullet
{
	// collision setup
	pCollisionConfig		= new btDefaultCollisionConfiguration();
	pBroadphase				= new btDbvtBroadphase();
	
	pCollisionDispatcher	= new btCollisionDispatcher(pCollisionConfig);
	pConstraintSolver		= new btSequentialImpulseConstraintSolver;
	pDynamicsWorld			= new btDiscreteDynamicsWorld(pCollisionDispatcher, pBroadphase, pConstraintSolver, pCollisionConfig);
}


- (void) tearDownGL
{
	if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;
}


- (void) tearDownScene
{
	// release buffers
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &mVertexBuffer);
	glDeleteVertexArraysOES(1, &mDiceVertexArray);
    
	// release texture
	GLuint textureID = self.objectEffect.texture2d0.name;
	glDeleteTextures( 1, &textureID);
	textureID = self.environmentEffect.textureCubeMap.name;
	glDeleteTextures( 1, &textureID);
	
	// release effects
    self.objectEffect = nil;
    self.environmentEffect = nil;
	
	// release bodies, the arrays release their elements on clear()
	pBoxBodies->clear();
	delete pBoxBodies;
	pBoxBodies = NULL;
	
	pWorldPlanes->clear();
	delete pWorldPlanes;
	pWorldPlanes = NULL;

	pCollisionShapes->clear();
	delete pCollisionShapes;
	pCollisionShapes = NULL;
	
	// TODO: probably, I should dealloc all of the bodies' motion states as well...
}


- (void) tearDownBullet
{
	// Cleanup Bullet
	delete pDynamicsWorld;
	pDynamicsWorld			= NULL;
	
	delete pBroadphase;
	pBroadphase				= NULL;
	delete pCollisionConfig;
	pCollisionConfig		= NULL;
	delete pCollisionDispatcher;
	pCollisionDispatcher	= NULL;
	delete pConstraintSolver;
	pConstraintSolver		= NULL;
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Interaction
// ---------------------------------------------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Handling the frame loop
// ---------------------------------------------------------------------------------------------------------------

// Update the world state
- (void) update
{
	// get two vectors: gravity and current motion
	float alpha = 0.1;
	double motion[3] = {0,0,0};
	CMAccelerometerData *newestAccel = self.motionManager.accelerometerData;
	if (firstAccelerometerData)
	{
		gravity[0] = newestAccel.acceleration.x;
		gravity[1] = newestAccel.acceleration.y;
		gravity[2] = newestAccel.acceleration.z;
		firstAccelerometerData = NO;
	}
	else
	{
		gravity[0] = gravity[0] * (1.0-alpha) + newestAccel.acceleration.x * alpha;
		gravity[1] = gravity[1] * (1.0-alpha) + newestAccel.acceleration.y * alpha;
		gravity[2] = gravity[2] * (1.0-alpha) + newestAccel.acceleration.z * alpha;
	}
	motion[0]	= newestAccel.acceleration.x - gravity[0];
	motion[1]	= newestAccel.acceleration.y - gravity[1];
	motion[2]	= newestAccel.acceleration.z - gravity[2];
	
	float gScaling = 0.0;			// still, should fall down as if the device was helt in portrait
	float mScaling = 300.0;		// emphasize changes a bit more, so that we notice it more
	pDynamicsWorld->setGravity( btVector3(gScaling * gravity[0] + mScaling *motion[0], 
										    gScaling * gravity[1] + mScaling *motion[1] - 10.0,
										    gScaling * gravity[2] + mScaling *motion[2]));

	// move physics forward
	float updateRate = 1 / self.timeSinceLastUpdate;
	pDynamicsWorld->stepSimulation(updateRate, 2, 1.0/150.0); // slow motion

//	// for debugging: print the timing on the 10th frame
//	static int i = 0;
//	if (i < 10)
//	{
//		i++;
//		if (i == 10)
//			CProfileManager::dumpAll();
//	}	
}


// GLKViewDelegate method
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	// draw background
	glPushGroupMarkerEXT(0, "Background");
	glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPopGroupMarkerEXT();
	
	// draw the skybox
	glPushGroupMarkerEXT(0, "Environment");
	[self.environmentEffect prepareToDraw];
	[self.environmentEffect draw];
	glPopGroupMarkerEXT();
	    
	// draw the boxes for the dice with effect framework
	glPushGroupMarkerEXT(0, "Dice");
	glBindVertexArrayOES(mDiceVertexArray);

	float objectTransform[16];
	for (int i = 0; i < self.diceNumber; i++)
	{
		pBoxBodies->at(i)->getCenterOfMassTransform().getOpenGLMatrix(objectTransform);
		GLKMatrix4 objectTransformMatrix = GLKMatrix4MakeWithArray(objectTransform);
		
		GLKMatrix4 cameraTransformMatrix	= GLKMatrix4MakeTranslation(0.0f, 0.0f, -30.0f);
		self.objectEffect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraTransformMatrix, objectTransformMatrix);
		
		[self.objectEffect prepareToDraw];
		glDrawArrays(GL_TRIANGLES, 0, 6*6);
	}
	glPopGroupMarkerEXT();
	
	// Discard the depth buffer
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
}


@end

