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
	GLuint _vertexBuffer;
	
	// Physics
	btDiscreteDynamicsWorld				*sDynamicsWorld;
	
	btBroadphaseInterface					*sBroadphase;
	btCollisionConfiguration				*sCollisionConfig;
	btCollisionDispatcher					*sCollisionDispatcher;
	btSequentialImpulseConstraintSolver	*sConstraintSolver;
	
	btAlignedObjectArray<btRigidBody*>		*sBoxBodies;
	btAlignedObjectArray<btRigidBody*>		*sWorldPlanes;
	btAlignedObjectArray<btCollisionShape*>	*sCollisionShapes;
	
	double gravity[3];
	BOOL firstAccelerometerData;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
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

@synthesize context		= _context;
@synthesize effect			= _effect;
@synthesize diceNumber		= _diceNumber;
@synthesize motionManager = _motionManager;


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
	if (!textureInfo)
		NSLog(@"%s %@", __PRETTY_FUNCTION__, outError);
	
	// load mesh for one dice to graphics card
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 8*4, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 8*4, BUFFER_OFFSET(3*4));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 8*4, BUFFER_OFFSET(6*4));

	// create a simple effect for the dice
	self.effect = [[GLKBaseEffect alloc] init];
	self.effect.light0.enabled			= GL_TRUE;
	self.effect.light0.diffuseColor	= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.effect.texture2d0.enabled		= GL_TRUE;
	self.effect.texture2d0.name		= textureInfo.name;
	self.effect.useConstantColor		= GL_TRUE;
	self.effect.constantColor			= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.effect.lightingType			= GLKLightingTypePerPixel;

	// compute projection matix
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f),	// FoV
															aspect,									// Sceen aspect
															0.1f, 100.0f);							// Near/far plane
    self.effect.transform.projectionMatrix = projectionMatrix;

	// -----------------------------------------------------------------------------------------------------------
	sDynamicsWorld->setGravity( btVector3(0, -10 ,0) );
	
	// create 6 planes / half spaces (world contraints)
	sWorldPlanes = new btAlignedObjectArray<btRigidBody*>();
	sCollisionShapes = new btAlignedObjectArray<btCollisionShape*>();
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
		sWorldPlanes->push_back(sFloorPlaneBody);
		sCollisionShapes->push_back(worldBoxSideShape);
		
		// add the body to the dynamics world
		sDynamicsWorld->addRigidBody(sFloorPlaneBody);
		
		// myMotionState is only a temp object, it values get copied into the rigid object
//		delete myMotionState;
//		myMotionState = NULL;
	}
	delete worldBoxShape;
	worldBoxShape = NULL;
	
	// create the some boxes
	sBoxBodies = new btAlignedObjectArray<btRigidBody*>();
	for (int i = 0; i < self.diceNumber; i++)
	{
		btCollisionShape* boxShape = new btBoxShape( btVector3(1, 1, 1) );
		
		btScalar mass = 0.20;		// positive mass means dynamic/moving object
		btVector3 localInertia(0, 0, 0);
		boxShape->calculateLocalInertia(mass, localInertia);
		
		btTransform objectTransform;
		objectTransform.setIdentity();
		float stride = 3.0;
		div_t division = div(i, 3);
		objectTransform.setOrigin( btVector3(division.rem * stride, division.quot * stride, 0) );

		btDefaultMotionState* myMotionState = new btDefaultMotionState(objectTransform);
		btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, myMotionState, boxShape, localInertia);
		rbInfo.m_restitution	= 1.0;
		btRigidBody* boxBody	= new btRigidBody(rbInfo);
		
		sBoxBodies->push_back(boxBody);
		sCollisionShapes->push_back(boxShape);
		
		// most applications shouldn't disable deactivation, but for this demo it is better.
		boxBody->setActivationState(DISABLE_DEACTIVATION);
		// add the body to the dynamics world
		sDynamicsWorld->addRigidBody(boxBody);
		
		// myMotionState is only a temp object, it values get copied into the rigid object
//		delete myMotionState;
//		myMotionState = NULL;
	}
}


- (void) setupBullet
{
	// collision setup
	sCollisionConfig	= new btDefaultCollisionConfiguration();
	sBroadphase			= new btDbvtBroadphase();
	
	sCollisionDispatcher	= new btCollisionDispatcher(sCollisionConfig);
	sConstraintSolver		= new btSequentialImpulseConstraintSolver;
	sDynamicsWorld			= new btDiscreteDynamicsWorld(sCollisionDispatcher, sBroadphase, sConstraintSolver, sCollisionConfig);
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
    glDeleteBuffers(1, &_vertexBuffer);
    
	// release texture
	GLuint textureID = self.effect.texture2d0.name;
	glDeleteTextures( 1, &textureID);
	
	// release effects
    self.effect = nil;
	
	// release bodies, the arrays release their elements on clear()
	sBoxBodies->clear();
	delete sBoxBodies;
	sBoxBodies = NULL;
	
	sWorldPlanes->clear();
	delete sWorldPlanes;
	sWorldPlanes = NULL;

	sCollisionShapes->clear();
	delete sCollisionShapes;
	sCollisionShapes = NULL;
}


- (void) tearDownBullet
{
	// Cleanup Bullet
	delete sDynamicsWorld;
	sDynamicsWorld			= NULL;
	
	delete sBroadphase;
	sBroadphase				= NULL;
	delete sCollisionConfig;
	sCollisionConfig		= NULL;
	delete sCollisionDispatcher;
	sCollisionDispatcher	= NULL;
	delete sConstraintSolver;
	sConstraintSolver		= NULL;
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
	sDynamicsWorld->setGravity( btVector3(gScaling * gravity[0] + mScaling *motion[0], 
										    gScaling * gravity[1] + mScaling *motion[1] - 10.0,
										    gScaling * gravity[2] + mScaling *motion[2]));

	// move physics forward
	float updateRate = 1 / self.timeSinceLastUpdate;
	sDynamicsWorld->stepSimulation(updateRate, 2, 1.0/150.0); // slow motion
	
	// for debugging: print the timing on the 10th frame
	static int i = 0;
	if (i < 10)
	{
		i++;
		if (i == 10)
			CProfileManager::dumpAll();
	}	
}


// GLKViewDelegate method
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	// draw background
	glPushGroupMarkerEXT(0, "Background");
	glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPopGroupMarkerEXT();
    
	// draw the boxes for the dice with effect framework
	glPushGroupMarkerEXT(0, "Dice");

	float objectTransform[16];
	for (int i = 0; i < self.diceNumber; i++)
	{
		sBoxBodies->at(i)->getCenterOfMassTransform().getOpenGLMatrix(objectTransform);
		GLKMatrix4 objectTransformMatrix = GLKMatrix4MakeWithArray(objectTransform);
		
		GLKMatrix4 cameraTransformMatrix	= GLKMatrix4MakeTranslation(0.0f, 0.0f, -30.0f);
		self.effect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraTransformMatrix, objectTransformMatrix);
		
		[self.effect prepareToDraw];
		glDrawArrays(GL_TRIANGLES, 0, 6*6);
	}
	glPopGroupMarkerEXT();
	
	// Discard the depth buffer
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
}


@end

