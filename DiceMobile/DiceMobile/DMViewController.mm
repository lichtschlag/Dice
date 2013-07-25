//
//  DMViewController.m
//  DiceMobile
//
//  Created by Leonhard Lichtschlag on 01/May/13.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "DMViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "btBulletDynamicsCommon.h"
#import <AudioToolbox/AudioServices.h>



#define BUFFER_OFFSET(i) ((char *)NULL + (i))

GLfloat gCubeVertexData[6*6*8] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,		tex0.x, tex0.y
	1.0f,-1.0f,-1.0f,		  1.0f, 0.0f, 0.0f,			0.499f, 0.0f,		// RIGHT FACE
    1.0f, 1.0f,-1.0f,         1.0f, 0.0f, 0.0f,			0.499f, 0.333f,
    1.0f,-1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.000f, 0.0f,
    1.0f,-1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.000f, 0.0f,
    1.0f, 1.0f,-1.0f,         1.0f, 0.0f, 0.0f,			0.499f, 0.333f,
    1.0f, 1.0f, 1.0f,         1.0f, 0.0f, 0.0f,			0.000f, 0.333f,
	
     1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			1.000f, 0.333f,		// TOP FACE
    -1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			0.501f, 0.333f,
     1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			1.000f, 0.0f,
     1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			1.000f, 0.0f,
    -1.0f, 1.0f,-1.0f,        0.0f, 1.0f, 0.0f,			0.501f, 0.333f,
    -1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,			0.501f, 0.0f,
    
    -1.0f, 1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,		0.000f, 0.666f,		// LEFT FACE
    -1.0f,-1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,		0.000f, 0.3343f,
    -1.0f, 1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,		0.499f, 0.666f,
    -1.0f, 1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,		0.499f, 0.666f,
    -1.0f,-1.0f,-1.0f,			-1.0f, 0.0f, 0.0f,		0.000f, 0.3343f,
    -1.0f,-1.0f, 1.0f,			-1.0f, 0.0f, 0.0f,		0.499f, 0.3343f,
    
    -1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,		0.501f, 0.3343f,	// BOTTOM FACE
     1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,		1.000f, 0.3343f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,		0.501f, 0.666f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,		0.501f, 0.666f,
     1.0f, -1.0f,-1.0f,        0.0f, -1.0f, 0.0f,		1.000f, 0.3343f,
     1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,		1.000f, 0.666f,
    
     1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.499f, 1.0f,		// FRONT FACE
    -1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.000f, 1.0f,
     1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.499f, 0.6676f,
     1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.499f, 0.6676f,
    -1.0f, 1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.000f, 1.0f,
    -1.0f,-1.0f, 1.0f,			0.0f, 0.0f, 1.0f,		0.000f, 0.6676f,
    
	 1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		0.501f, 0.6676f,	// BACK FACE
	-1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		1.000f, 0.6676f,
	 1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		0.501f, 1.0f,
	 1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		0.501f, 1.0f,
	-1.0f,-1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		1.000f, 0.6676f,
	-1.0f, 1.0f, -1.0f,       0.0f, 0.0f, -1.0f,		1.000f, 1.0f
};


typedef NS_ENUM(NSInteger, L2RInteractionState)
{
    L2RInteractionStateNormal,
	L2RInteractionStateGravity,
	L2RInteractionStateAnimatingCompression,	// I could just use one animation state for arbitrary start and ends
    L2RInteractionStateAnimatingLeftSplit,		// but this allows for different animation styles
	L2RInteractionStateAnimatingLeftRotate,
    L2RInteractionStateAnimatingRightSplit,
    L2RInteractionStateAnimatingRightRotate,
    L2RInteractionStateAnimatingUpSplit,
    L2RInteractionStateAnimatingUpRotate,
    L2RInteractionStateAnimatingDownSplit,
    L2RInteractionStateAnimatingDownRotate,
    L2RInteractionStateAnimatingMerge,
};


typedef NS_ENUM(NSInteger, L2RBoxFace)
{
    L2RBoxFaceFront,
	L2RBoxFaceBack,
    L2RBoxFaceLeft,
	L2RBoxFaceRight,
    L2RBoxFaceTop,
	L2RBoxFaceBottom
};

const NSTimeInterval kAnimationDurationSplit		= 0.20;
const NSTimeInterval kAnimationDurationRotation		= 0.60;
const NSTimeInterval kAnimationDurationMerge		= 0.20;
const NSTimeInterval kAnimationDurationCompression	= 0.35;
const NSTimeInterval kDiceMass			= 0.2;


// ===============================================================================================================
@interface DMViewController () 
// ===============================================================================================================
{
	GLuint mVertexBuffer;
	GLuint mDiceVertexArray;
	
	// Physics
	btDiscreteDynamicsWorld					*pDynamicsWorld;
	
	btBroadphaseInterface					*pBroadphase;
	btCollisionConfiguration				*pCollisionConfig;
	btCollisionDispatcher					*pCollisionDispatcher;
	btSequentialImpulseConstraintSolver		*pConstraintSolver;
	
	btAlignedObjectArray<btRigidBody*>		*pBoxBodies;
	btAlignedObjectArray<btRigidBody*>		*pWorldPlanes;
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

@property			L2RInteractionState currentState;
@property			L2RInteractionState currentFace;  // when an animation starts currentFace points to target
@property			NSDate*			animationStartDate;
@property			NSMutableArray*	animationStartPositions;
@property			NSMutableArray*	currentFacePositions;
@property			NSMutableArray*	textures;
@property			GLKTextureInfo *cubeMapInfo;

@property	SystemSoundID audioEffect;



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

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
// ---------------------------------------------------------------------------------------------------------------

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.diceNumber = 16;
	self.currentState = L2RInteractionStateNormal;
	self.currentFace  = L2RBoxFaceFront;
	[self calculateCurrentFacePositions];
	
	[self setupButtons];
	[self setupGL];
	[self setupBullet];
	[self setupScene];
	
	self.motionManager = [[CMMotionManager alloc] init];
	self.motionManager.accelerometerUpdateInterval = 0.16; // 60Hz
	[self.motionManager startAccelerometerUpdates];
	memset(gravity, 0, sizeof(gravity));
	firstAccelerometerData = YES;
	
	// load a sound
	NSURL *soundURL  = [[NSBundle mainBundle] URLForResource:@"klack" withExtension:@"m4a"];
	SystemSoundID audioEffect;
	OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &audioEffect);
	if (error == kAudioServicesNoError)
	{
		self.audioEffect = audioEffect;
	}
}


// not called in iOS6 anymore
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


- (void) loadTextures
{
	self.textures = [NSMutableArray array];
	
	// load texture data for the dice
	for (int i = 0; i < self.diceNumber; i++)
	{
		NSError *outError = nil;
		NSString* textureName			= [[NSString  alloc] initWithFormat:@"texture.%d", i];
		NSURL *textureURL				= [[NSBundle mainBundle] URLForResource:textureName withExtension:@"jpg"];
		NSDictionary *options			= [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithBool:NO],  GLKTextureLoaderGenerateMipmaps,
										   [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];
		GLKTextureInfo *textureInfo	= [GLKTextureLoader textureWithContentsOfURL:textureURL options:options error:&outError];
		if (!textureInfo)
			NSLog(@"%s %@", __PRETTY_FUNCTION__, outError);
		
		[self.textures addObject:textureInfo];
	}
	
	// load environment map
	NSError *outError = nil;
	NSURL *textureURL					= [[NSBundle mainBundle] URLForResource:@"EnvironmentCubeMap" withExtension:@"jpg"];
	NSDictionary *options				= [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithBool:NO],  GLKTextureLoaderGenerateMipmaps,
										   nil];
	self.cubeMapInfo	= [GLKTextureLoader cubeMapWithContentsOfURL:textureURL options:options error:&outError];
	
	if (!self.cubeMapInfo)
		NSLog(@"%s %@", __PRETTY_FUNCTION__, outError);
}



- (void) setupScene
{
	[EAGLContext setCurrentContext:self.context];
	[self loadTextures];
	
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
	GLKTextureInfo *aTexture =  (GLKTextureInfo *)self.textures[0];
//	self.objectEffect = [[GLKReflectionMapEffect alloc] init];
	self.objectEffect = [[GLKBaseEffect alloc] init];
	self.objectEffect.light0.enabled			= GL_TRUE;
	self.objectEffect.light0.diffuseColor		= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.objectEffect.light0.position			= GLKVector4Make(0.0f, 1.0f, 1.0f, 0.0f);
//	self.objectEffect.lightModelAmbientColor	= GLKVector4Make(1.0f, 1.0f, 1.0f, 0.0f);
	self.objectEffect.texture2d0.enabled		= GL_TRUE;
	self.objectEffect.texture2d0.name			= aTexture.name;
	self.objectEffect.useConstantColor			= GL_TRUE;
	self.objectEffect.constantColor				= GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
	self.objectEffect.lightingType				= GLKLightingTypePerPixel;
//	self.objectEffect.textureCubeMap.name		= cubeMapInfo.name;
//	self.objectEffect.textureCubeMap.envMode	= GLKTextureEnvModeModulate;

	// compute projection matix
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(75.0f),	// FoV
															aspect,									// Sceen aspect
															0.1f, 100.0f);							// Near/far plane
    self.objectEffect.transform.projectionMatrix = projectionMatrix;
	
	// create skybox effect
	self.environmentEffect = [[GLKSkyboxEffect alloc] init]; 
	self.environmentEffect.transform.projectionMatrix = projectionMatrix;
	self.environmentEffect.textureCubeMap.name = self.cubeMapInfo.name;
	self.environmentEffect.xSize = 100.0f;
	self.environmentEffect.ySize = 100.0f;
	self.environmentEffect.zSize = 100.0f;
	
	// -----------------------------------------------------------------------------------------------------------
	pDynamicsWorld->setGravity( btVector3(0, -10 ,0) );
	
	// create 6 planes / half spaces (world contraints)
	pWorldPlanes = new btAlignedObjectArray<btRigidBody*>();
	pCollisionShapes = new btAlignedObjectArray<btCollisionShape*>();
	btBoxShape* worldBoxShape = new btBoxShape( btVector3(5.25, 7, 10) );		// world constraints helper object
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
	[self setupBoxes];
}


- (void) setupBoxes
{
	// release bodies
	if (pBoxBodies)
	{
		for (int i = 0; i < self.diceNumber; i++)
		{
			btRigidBody* boxBody = pBoxBodies->at(i);

			btMotionState* oldMotionState = 	pBoxBodies->at(i)->getMotionState();
			delete oldMotionState;

			pDynamicsWorld->removeRigidBody(boxBody);
			delete boxBody;
		}

		pBoxBodies->clear();
		delete pBoxBodies;
		pBoxBodies = NULL;
	}
	
	// and add them again
	// I do it in this hard-reset way, because otherwise the inertia of a box carries over from it's last simulated state
	pBoxBodies = new btAlignedObjectArray<btRigidBody*>();
	
	// create collision shape that all dice share
	btCollisionShape* boxShape = new btBoxShape( btVector3(1, 1, 1) );
	btScalar mass = kDiceMass;		// positive mass means dynamic/moving object
	btVector3 localInertia(0, 0, 0);
	boxShape->calculateLocalInertia(mass, localInertia);
	pCollisionShapes->push_back(boxShape);
	
	for (int i = 0; i < self.diceNumber; i++)
	{
		// extract target from our data storage
		NSValue* transformAsValue = self.currentFacePositions[i];
		GLKMatrix4 objectTransformMatrix;
		[transformAsValue getValue:&objectTransformMatrix];

		// feed into bullet
		btTransform objectTransform;
		objectTransform.setFromOpenGLMatrix(objectTransformMatrix.m);
		
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

	// apparently one cannot delete it, leads to crashes.
	//	delete boxShape;
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
	[self computeGravity];

	// move physics forward
	if (self.currentState  == L2RInteractionStateGravity)
	{
		float updateRate = 1 / self.timeSinceLastUpdate;
		pDynamicsWorld->stepSimulation(updateRate, 2, 1.0/150.0); // slow motion, because it's more fun

		//	// for debugging: print the timing on the 10th frame
		//	static int i = 0;
		//	if (i < 10)
		//	{
		//		i++;
		//		if (i == 10)
		//			CProfileManager::dumpAll();
		//	}
	}
	
	// animate
	else if (self.currentState  != L2RInteractionStateNormal)
	{
		[self animationStep];
	}
}


- (void) animationStep
{
	// let's figure out how far we are in the current animation
	NSTimeInterval secondsSinceAnimationStart = [[NSDate date] timeIntervalSinceDate:self.animationStartDate];

	float progress = 0.0f;
	BOOL animationHasEnded = NO;
	
	// for all boxes, animate from their last safe position to the target position with time factor t
	switch (self.currentState)
	{
			// transform back from a gravity situation
		case L2RInteractionStateAnimatingCompression:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationCompression );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingMerge;
				[self prepareForAnimationStart];
				[self calculateCurrentFacePositions];
			}
			
			break;
			

		// multistep animations
		// -----------------------------------------------------------------------------------------------------
		case L2RInteractionStateAnimatingUpSplit:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationSplit );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingUpRotate;
				[self prepareForAnimationStart];
				
				switch (self.currentFace)
				{
					case L2RBoxFaceFront:
						self.currentFace = L2RBoxFaceTop;
						break;
					case L2RBoxFaceRight:
						self.currentFace = L2RBoxFaceTop;
						break;
					case L2RBoxFaceBack:
						self.currentFace = L2RBoxFaceTop;
						break;
					case L2RBoxFaceLeft:
						self.currentFace = L2RBoxFaceTop;
						break;
					case L2RBoxFaceTop:
						self.currentFace = L2RBoxFaceBack;
						break;
					case L2RBoxFaceBottom:
						self.currentFace = L2RBoxFaceFront;
						break;
						
					default:
						NSAssert(NO, @"Unexpected switch statement");
						break;
				}
				[self calculateCurrentFacePositions];
			}
			
			break;

		case L2RInteractionStateAnimatingDownSplit:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationSplit );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingDownRotate;
				[self prepareForAnimationStart];
				
				switch (self.currentFace)
				{
					case L2RBoxFaceFront:
						self.currentFace = L2RBoxFaceBottom;
						break;
					case L2RBoxFaceRight:
						self.currentFace = L2RBoxFaceBottom;
						break;
					case L2RBoxFaceBack:
						self.currentFace = L2RBoxFaceBottom;
						break;
					case L2RBoxFaceLeft:
						self.currentFace = L2RBoxFaceBottom;
						break;
					case L2RBoxFaceTop:
						self.currentFace = L2RBoxFaceFront;
						break;
					case L2RBoxFaceBottom:
						self.currentFace = L2RBoxFaceBack;
						break;
						
					default:
						NSAssert(NO, @"Unexpected switch statement");
						break;
				}
				[self calculateCurrentFacePositions];
			}
			
			break;

		case L2RInteractionStateAnimatingLeftSplit:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationSplit );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingLeftRotate;
				[self prepareForAnimationStart];
				
				switch (self.currentFace)
				{
					case L2RBoxFaceFront:
						self.currentFace = L2RBoxFaceLeft;
						break;
					case L2RBoxFaceRight:
						self.currentFace = L2RBoxFaceFront;
						break;
					case L2RBoxFaceBack:
						self.currentFace = L2RBoxFaceRight;
						break;
					case L2RBoxFaceLeft:
						self.currentFace = L2RBoxFaceBack;
						break;
					case L2RBoxFaceTop:
						self.currentFace = L2RBoxFaceLeft;
						break;
					case L2RBoxFaceBottom:
						self.currentFace = L2RBoxFaceLeft;
						break;

					default:
						NSAssert(NO, @"Unexpected switch statement");
						break;
				}
				[self calculateCurrentFacePositions];
			}
			
			break;
		
		case L2RInteractionStateAnimatingRightSplit:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationSplit );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingRightRotate;
				[self prepareForAnimationStart];
				
				switch (self.currentFace)
				{
					case L2RBoxFaceFront:
						self.currentFace = L2RBoxFaceRight;
						break;
					case L2RBoxFaceRight:
						self.currentFace = L2RBoxFaceBack;
						break;
					case L2RBoxFaceBack:
						self.currentFace = L2RBoxFaceLeft;
						break;
					case L2RBoxFaceLeft:
						self.currentFace = L2RBoxFaceFront;
						break;
					case L2RBoxFaceTop:
						self.currentFace = L2RBoxFaceRight;
						break;
					case L2RBoxFaceBottom:
						self.currentFace = L2RBoxFaceRight;
						break;
						
					default:
						NSAssert(NO, @"Unexpected switch statement");
						break;
				}
				[self calculateCurrentFacePositions];
			}
			
			break;
			
		// ----------------------------------------------------------------------------------------------------------
		case L2RInteractionStateAnimatingUpRotate:
		case L2RInteractionStateAnimatingDownRotate:
		case L2RInteractionStateAnimatingLeftRotate:
		case L2RInteractionStateAnimatingRightRotate:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationRotation );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateAnimatingMerge;
				[self prepareForAnimationStart];
				[self calculateCurrentFacePositions];
			}
			break;
			
		case L2RInteractionStateAnimatingMerge:
			
			progress = ( secondsSinceAnimationStart / kAnimationDurationMerge );
			[self animationSubStepWithTimeFactor:progress];
			
			animationHasEnded =  (progress > 1.0f);
			if (animationHasEnded)
			{
				self.currentState = L2RInteractionStateNormal;
				AudioServicesPlaySystemSound(self.audioEffect);
				[self setupBoxes];
			}
			break;
			
		default:
			NSAssert(NO, @"Unexpected switch statement");
			break;
	}
}


- (void) animationSubStepWithTimeFactor:(float)time
{	
	for (int i = 0; i < self.diceNumber; i++)
	{
		GLKMatrix4 startTransform;
		GLKMatrix4 endTransform;
		NSValue *transformAsValue = self.animationStartPositions[i];
		[transformAsValue getValue:&startTransform];
		transformAsValue = self.currentFacePositions[i];
		[transformAsValue getValue:&endTransform];
		
		// extract target from our data storage
		GLKMatrix4 middleOfAnimationTransform = [self interpolateTransformBetweenStartTransform:startTransform
																				   endTransform:endTransform
																					   progress:time];
		
		// feed into bullet
		btTransform objectTransform;
		objectTransform.setFromOpenGLMatrix(middleOfAnimationTransform.m);
		
		btDefaultMotionState* myMotionState = new btDefaultMotionState(objectTransform);
		btMotionState* oldMotionState = 	pBoxBodies->at(i)->getMotionState();
		pBoxBodies->at(i)->setMotionState(myMotionState);
		delete oldMotionState;
	}
}


- (void) computeGravity
{
	// get two vectors: gravity and current motion
	float alpha = 0.1f;
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
	
	float gScaling = 0.0f;			// still, should fall down as if the device was helt in portrait
	float mScaling = 300.0f;		// emphasize changes a bit more, so that we notice it more
	pDynamicsWorld->setGravity( btVector3(gScaling * gravity[0] + mScaling *motion[0],
										  gScaling * gravity[1] + mScaling *motion[1] -  2.0f,
										  gScaling * gravity[2] + mScaling *motion[2] - 10.0f));
}


// GLKViewDelegate method
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	// draw background
	glPushGroupMarkerEXT(0, "Background");
	glClearColor(0.05f, 0.05f, 0.05f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPopGroupMarkerEXT();
	
	// draw the skybox
	glPushGroupMarkerEXT(0, "Environment");
	[self.environmentEffect prepareToDraw];
//	[self.environmentEffect draw];
	glPopGroupMarkerEXT();
	    
	// draw the boxes for the dice with effect framework
	glPushGroupMarkerEXT(0, "Dice");
	glBindVertexArrayOES(mDiceVertexArray);

	float objectTransform[16];
	for (int i = 0; i < self.diceNumber; i++)
	{
		pBoxBodies->at(i)->getCenterOfMassTransform().getOpenGLMatrix(objectTransform);
		GLKMatrix4 objectTransformMatrix	= GLKMatrix4MakeWithArray(objectTransform);
		
		GLKMatrix4 cameraTransformMatrix	= GLKMatrix4MakeTranslation(0.0f, 0.0f, -15.0f);
//		GLKMatrix4 cameraTransformMatrix	= GLKMatrix4MakeTranslation(0.0f, 0.0f, -30.0f);
		self.objectEffect.transform.modelviewMatrix = GLKMatrix4Multiply(cameraTransformMatrix, objectTransformMatrix);

		GLKTextureInfo *aTexture =  (GLKTextureInfo *)self.textures[i];
		self.objectEffect.texture2d0.name			= aTexture.name;

		[self.objectEffect prepareToDraw];
		glDrawArrays(GL_TRIANGLES, 0, 6*6);
	}
	glPopGroupMarkerEXT();
	
	// Discard the depth buffer
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
}


//// -----------------------------------------------------------------------------------------------------------------
//#pragma mark -
//#pragma mark touch detection
//// -----------------------------------------------------------------------------------------------------------------
//
//- (IBAction) tapGesture:(id)sender
//{
//	if ([(UITapGestureRecognizer *)sender state] == UIGestureRecognizerStateEnded)
//	{
//		CGPoint tapPosition = [(UITapGestureRecognizer *)sender locationInView:self.view];
//		int index = [self indexOfDiceAtPointInView:tapPosition];
//		
//		// switch the texture fo that object to show it was selected
//		
//		
//	}
//}
//
//
//- (int) indexOfDiceAtPointInView:(CGPoint)pointInView
//{
//	// prepare a second frame buffer that ww will render all the dice to for selection purposes
//	// each tab triggers one reder call
//	
//	GLuint colorRenderbuffer;
//	GLuint framebuffer;
//	
//	glGenFramebuffers(1, &framebuffer);
//	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//	glGenRenderbuffers(1, &colorRenderbuffer);
//	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
//	
//	NSInteger height = ((GLKView *)self.view).drawableHeight;
//	NSInteger width = ((GLKView *)self.view).drawableWidth;
//	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, width, height);
//
//	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER, colorRenderbuffer);
//	
//	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//	if (status != GL_FRAMEBUFFER_COMPLETE)
//	{
//		NSLog(@"Framebuffer status: %x", (int)status);
//		return 0;
//	}
//
//	// now render all the dice so we'll kno which one to pick
////	[self render:DM_SELECT];
//	
//	CGFloat scale = UIScreen.mainScreen.scale;		// todo maybe call glkview's property instead
//	Byte returnedPixelColor[4] = {0, 0, 0, 0};
//	glReadPixels(pointInView.x * scale,
//				 (height - (pointInView.y * scale)),
//				 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, returnedPixelColor);
//	
//	// clean up
//	glDeleteRenderbuffers(1, &colorRenderbuffer);
//	glDeleteFramebuffers(1, &framebuffer);
//	
//	return returnedPixelColor[0];
//}
//

// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Finger Interaction
// -----------------------------------------------------------------------------------------------------------------

// State machine will transition from animating states to normal state in update function after animation is done
- (IBAction) userDidTap:(UIGestureRecognizer *)sender;
{
	if (self.currentState == L2RInteractionStateNormal)
		self.currentState = L2RInteractionStateGravity;
	
	else if (self.currentState == L2RInteractionStateGravity)
	{
		self.currentState = L2RInteractionStateAnimatingCompression;
		self.currentFace = L2RBoxFaceFront;
		[self prepareForAnimationStart];
		[self calculateCurrentFacePositions];
	}
}


- (IBAction) userDidSwipeLeft:(UIGestureRecognizer *)sender;
{
	if (self.currentState == L2RInteractionStateNormal)
	{
		self.currentState = L2RInteractionStateAnimatingRightSplit;
		[self prepareForAnimationStart];
		[self calculateCurrentFacePositions];
		AudioServicesPlaySystemSound(self.audioEffect);

	}
}


- (IBAction) userDidSwipeRight:(UIGestureRecognizer *)sender;
{
	if (self.currentState == L2RInteractionStateNormal)
	{
		self.currentState = L2RInteractionStateAnimatingLeftSplit;
		[self prepareForAnimationStart];
		[self calculateCurrentFacePositions];
		AudioServicesPlaySystemSound(self.audioEffect);

	}
}


- (IBAction) userDidSwipeDown:(UIGestureRecognizer *)sender;
{
	if (self.currentState == L2RInteractionStateNormal)
	{
		self.currentState = L2RInteractionStateAnimatingUpSplit;
		[self prepareForAnimationStart];
		[self calculateCurrentFacePositions];
		AudioServicesPlaySystemSound(self.audioEffect);

	}
}


- (IBAction) userDidSwipeUp:(UIGestureRecognizer *)sender;
{
	if (self.currentState == L2RInteractionStateNormal)
	{
		self.currentState = L2RInteractionStateAnimatingDownSplit;
		[self prepareForAnimationStart];
		[self calculateCurrentFacePositions];
		AudioServicesPlaySystemSound(self.audioEffect);

	}
}


- (IBAction) userDidTapShareButton:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self composeEmailAndDisplaySheet];
}

- (IBAction) userDidTapInfoButton:(id)sender
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}


// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Custom Button Look
// -----------------------------------------------------------------------------------------------------------------

- (void) setupButtons
{
	UIImage *buttonImage;
	
	// creating an in-memory image as a template for the buttons
	CGFloat radius = 40.0f;
	CGFloat width = radius * 2+15;
	UIColor *foregroundColor = [UIColor whiteColor];
	
	buttonImage = [self resizableImageWithForegroundColor:foregroundColor
												withWidth:width
												   radius:radius
												 forState:UIControlStateNormal];
	[self.infoButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[self.shareButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	
	buttonImage = [self resizableImageWithForegroundColor:foregroundColor
												withWidth:width
												   radius:radius
												 forState:UIControlStateHighlighted];
	[self.infoButton setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
	[self.shareButton setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
}


- (UIImage *) resizableImageWithForegroundColor:(UIColor *)foregroundColor
									  withWidth:(CGFloat)width
										 radius:(CGFloat)radius
									   forState:(UIControlState)buttonState
{
	// set up drawing context
	UIGraphicsBeginImageContext(CGSizeMake(width, width));
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
	// drawing state image
	[[UIColor clearColor] set];
	CGContextFillRect(context, CGRectMake(0, 0, width, width));
	
	[foregroundColor set];
	CGContextSetShadowWithColor(context, CGSizeMake(0,0), 6.0f, foregroundColor.CGColor);
	
	CGPathRef roundedRectPath = [self newPathForRoundedRect:CGRectInset(CGRectMake(0, 0, width, width),5,5) radius:radius];
	CGContextAddPath(context, roundedRectPath);
	
	if (buttonState == UIControlStateNormal)
		CGContextStrokePath(context);
	else
		CGContextFillPath(context);
	
	// take down drawing context
	UIGraphicsPopContext();
	UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGPathRelease(roundedRectPath);
	
	return [tempImage resizableImageWithCapInsets:UIEdgeInsetsMake(radius +6, radius +6, radius +6, radius +6)];
}


- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	// helper function for the button images
	CGMutablePathRef retPath = CGPathCreateMutable();
	
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	
	CGPathCloseSubpath(retPath);
	
	return retPath;
}



// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Emailing
// -----------------------------------------------------------------------------------------------------------------

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void) composeEmailAndDisplaySheet
{
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	mailViewController.mailComposeDelegate = self;
	mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	[mailViewController setSubject:@"We should hire Leonhard."];
	
	// Fill out the email body text
	NSString *emailBody = @"Look at this nice demo, this really deserves a WWDC ticket: http://www.lichtschlag.net/wwdcdemo/package.zip";
	[mailViewController setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:mailViewController animated:YES completion:nil];
}


- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Animation and Position Helpers
// -----------------------------------------------------------------------------------------------------------------

- (void) prepareForAnimationStart
{
	// captures current time and the positions of all blocks
	self.animationStartDate = [NSDate date];
	self.animationStartPositions = [NSMutableArray array];

	float objectTransform[16];  // helper data object
	for (int i = 0; i < self.diceNumber; i++)
	{
		pBoxBodies->at(i)->getCenterOfMassTransform().getOpenGLMatrix(objectTransform);
		GLKMatrix4 objectTransformMatrix = GLKMatrix4MakeWithArray(objectTransform);
		
		NSValue* transformAsValue = [NSValue valueWithBytes:&objectTransformMatrix
												   objCType:@encode(GLKMatrix4)];
		[self.animationStartPositions addObject:transformAsValue];
	}
}


- (void) calculateCurrentFacePositions
{
	self.currentFacePositions = [NSMutableArray array];
	
	btVector3 rotationAxis = btVector3(0.0f, 1.0f, 0.0f);
	btQuaternion rotationAsQuarterion;

	// for the multistep animations the animations will have three endPositions:
	// split, that is just a translated cube
	// rotate, that is a translation plus rotation
	// merge, that is only the applied rotation and no translation
	BOOL shouldAmplifyXStride		= (   self.currentState == L2RInteractionStateAnimatingRightSplit
									   || self.currentState == L2RInteractionStateAnimatingRightRotate
									   || self.currentState == L2RInteractionStateAnimatingLeftSplit
									   || self.currentState == L2RInteractionStateAnimatingLeftRotate
									   || self.currentState == L2RInteractionStateAnimatingUpSplit
									   || self.currentState == L2RInteractionStateAnimatingUpRotate
									   || self.currentState == L2RInteractionStateAnimatingDownSplit
									   || self.currentState == L2RInteractionStateAnimatingDownRotate
									   || self.currentState == L2RInteractionStateAnimatingCompression
									   );
	
	BOOL shouldAmplifyYStride		= (   self.currentState == L2RInteractionStateAnimatingUpSplit
									   || self.currentState == L2RInteractionStateAnimatingUpRotate
									   || self.currentState == L2RInteractionStateAnimatingDownSplit
									   || self.currentState == L2RInteractionStateAnimatingDownRotate
									   || self.currentState == L2RInteractionStateAnimatingRightSplit
									   || self.currentState == L2RInteractionStateAnimatingRightRotate
									   || self.currentState == L2RInteractionStateAnimatingLeftSplit
									   || self.currentState == L2RInteractionStateAnimatingLeftRotate
									   || self.currentState == L2RInteractionStateAnimatingCompression
									   );

	// shouldAmplifyXStride = shouldAmplifyXStride && (target and current face do not have the same y vector)
	// shouldAmplifyYStride = shouldAmplifyYStride && (target and current face do not have the same x vector)
	
	// rotation in dependant on target face
	// the directions of rotations is dependant on the wayt he textures are layed out, and one should be able to
	// insert an image here
	switch (self.currentFace)
	{
		case L2RBoxFaceFront:
			rotationAsQuarterion = btQuaternion(rotationAxis, 0.0f);
			break;
		case L2RBoxFaceBack:
			rotationAsQuarterion = btQuaternion(rotationAxis,  M_PI);
			break;
		case L2RBoxFaceRight:
			rotationAsQuarterion = btQuaternion(rotationAxis, -M_PI_2);
			break;
		case L2RBoxFaceLeft:
			rotationAsQuarterion = btQuaternion(rotationAxis,  M_PI_2);
			break;
		case L2RBoxFaceTop:
			rotationAxis = btVector3(1.0f, 0.0f, 0.0f);
			rotationAsQuarterion = btQuaternion(rotationAxis,  M_PI_2);
			break;
		case L2RBoxFaceBottom:
			rotationAxis = btVector3(1.0f, 0.0f, 0.0f);
			rotationAsQuarterion = btQuaternion(rotationAxis, -M_PI_2);
			break;
			
		default:
			NSAssert(NO, @"Unexpected Switch statement");
			break;
	}
		
	float strideX = shouldAmplifyXStride ? 3.0f : 2.0f;
	float strideY = shouldAmplifyYStride ? 3.0f : 2.0f;

	// transform is dependant on dice id
	for (int i = 0; i < self.diceNumber; i++)
	{
		btTransform objectTransform;
		objectTransform.setIdentity();
		div_t division = div(i, 4);
		objectTransform.setRotation(rotationAsQuarterion);
		objectTransform.setOrigin( btVector3(division.rem  * strideX - 1.5f*strideX,
											 division.quot * strideY - 1.5f*strideY,
											 4.0f) );

		float objectTransformData[16];		// helper data object
		objectTransform.getOpenGLMatrix(objectTransformData);
		GLKMatrix4 objectTransformMatrix = GLKMatrix4MakeWithArray(objectTransformData);
	
		NSValue* transformAsValue = [NSValue valueWithBytes:&objectTransformMatrix
												   objCType:@encode(GLKMatrix4)];
		[self.currentFacePositions addObject:transformAsValue];
	}
}


- (GLKMatrix4) interpolateTransformBetweenStartTransform:(GLKMatrix4)startTransform
											endTransform:(GLKMatrix4)endTransform
												progress:(float)progress
{
	progress = MIN(1.0f, progress);
	progress = MAX(0.0f, progress);
	
	// split into position and rotational aspects
	GLKVector4 startTranslation = GLKMatrix4GetColumn(startTransform, 3);
	GLKVector4 endTranslation	= GLKMatrix4GetColumn(endTransform, 3);
	
	// interpolate between the translative part linearly
	// that is middle = start + (end-start) * progress
	GLKVector4 middleTranslation= GLKVector4Lerp(startTranslation, endTranslation, progress);
	
	// interpolate between the rotational part with a SLERP
	// TODO: test if I do need to the reduction beforehand
	GLKQuaternion startQuart	= GLKQuaternionMakeWithMatrix4(startTransform);
	GLKQuaternion endQuart		= GLKQuaternionMakeWithMatrix4(endTransform);
	
	GLKQuaternion middleQuart	= GLKQuaternionSlerp( startQuart, endQuart, progress );
	
	// combine and return
	GLKMatrix4 middleTransform	= GLKMatrix4Identity;
	middleTransform	= GLKMatrix4TranslateWithVector4(middleTransform, middleTranslation);
	middleTransform	= GLKMatrix4Multiply(middleTransform, GLKMatrix4MakeWithQuaternion(middleQuart));

	return middleTransform;
}


GLKMatrix4 GLKMatrix4GetRotation(GLKMatrix4 matrix)
{
	GLKMatrix4 returnMatrix = matrix;
	GLKMatrix4SetColumn(returnMatrix, 3, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f));
	return returnMatrix;
}


@end

