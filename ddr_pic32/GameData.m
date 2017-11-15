//
//  GameData.m
//  ddr_pic32
//
//  Adapted by Drew Dunne on 11/14/17.
//
//  Created by Matt Gallagher on 15/02/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "GameData.h"
#import "GameObject.h"
#include <mach/mach_time.h>

typedef enum {
    kLeftArrow,
    kRightArrow,
    kUpArrow,
    kDownArrow
} kArrowType;

NSString *GAME_OBJECT_NEW_NOTIFICATION = @"GameObjectNewNotification";

const double GAME_ASPECT = 16.0 / 10.0;
const double GAME_UPDATE_DURATION = 0.03;

const double ARROW_SPEED = 0.35;
const double ARROW_SIZE = 0.1;
const double HALF_ARROW_PAD = 0.02;

NSString *ARROW_OUTLINE_KEY = @"outline";
NSString *ARROW_KEY_BASE = @"arrow";

@implementation GameData

//SYNTHESIZE_SINGLETON_FOR_CLASS(GameData);

+ (GameData *)sharedGameData {
    static GameData *sharedGameData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameData = [[self alloc] init];
    });
    return sharedGameData;
}

//
// init
//
// Init method for the object.
//
- (id)init
{
	self = [super init];
	if (self != nil)
	{
		gameObjects = [[NSMutableDictionary alloc] init];

		srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF));
	}
	return self;
}

//
// gameWidth
//
// Returns the width for the game area. Defaults to screen width.
//
- (double)gameWidth
{
	static double gameWidth = 0;
	
	if (gameWidth == 0)
	{
		NSSize screenSize = [[NSScreen mainScreen] frame].size;
		if ((screenSize.width / screenSize.height) > GAME_ASPECT)
		{
			screenSize.width = screenSize.height * GAME_ASPECT;
		}
		gameWidth = screenSize.width;
	}

	return gameWidth;
}

//
// gameHeight
//
// Returns the height for the game area. Defaults to screen height.
//
- (double)gameHeight
{
	static double gameHeight = 0;
	
	if (gameHeight == 0)
	{
		NSSize screenSize = [[NSScreen mainScreen] frame].size;
		if ((screenSize.width / screenSize.height) < GAME_ASPECT)
		{
			screenSize.height = screenSize.width / GAME_ASPECT;
		}
		gameHeight = screenSize.height;
	}

	return gameHeight;
}

#pragma mark gameObjects accessors

//
// gameObjects
//
// Accessor for the dictionary of game objects
//
- (NSDictionary *)gameObjects
{
	return gameObjects;
}

#pragma mark gameObjects Management

//
// addGameObject:forKey:
//
// The object is added to the gameObjects dictionary
// using the "name" as a key and notification is sent.
//
- (void)addGameObject:(GameObject *)newGameObject forKey:(NSString *)gameObjectKey
{
	[gameObjects setObject:newGameObject forKey:gameObjectKey];
	newGameObject.keyInGameData = gameObjectKey;
	
	[[NSNotificationCenter defaultCenter]
		postNotificationName:GAME_OBJECT_NEW_NOTIFICATION object:gameObjectKey];
}

//
// removeGameObjectForKey:
//
// The object is removed from the gameObjects dictionary
// using the "name" as a key.
//
- (void)removeGameObjectForKey:(NSString *)gameObjectKey
{
	((GameObject *)[gameObjects objectForKey:gameObjectKey]).keyInGameData = nil;
	[gameObjects removeObjectForKey:gameObjectKey];
}

+ (NSString *)keyForArrow:(kArrowType)arrow withKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@-%@-%d", ARROW_KEY_BASE, key, arrow];
}

+ (NSString *)stringForArrow:(kArrowType)arrow {
    switch (arrow) {
        case kUpArrow:
            return @"up";
        case kLeftArrow:
            return @"left";
        case kDownArrow:
            return @"down";
        case kRightArrow:
            return @"right";
        default:
            return @"";
    }
}


// Aligns the arrows in the center and evenly spaced apart
- (void)alignHorizontalArrows:(kArrowType[])arrows size:(size_t)n ForKey:(NSString *)key {
    const double center = 0.5 * GAME_ASPECT;
    size_t i;
    for (i = 0; i < n; i++) {
        kArrowType arrow = arrows[i];
        GameObject *arrowObj = [[self gameObjects] objectForKey:[GameData keyForArrow:arrow withKey:key]];
        switch (arrow) {
            case kUpArrow:
                arrowObj.x = center + ARROW_SIZE/2 + 2*HALF_ARROW_PAD;
                break;
            case kLeftArrow:
                arrowObj.x = center - ARROW_SIZE - 8*HALF_ARROW_PAD;
                break;
            case kDownArrow:
                arrowObj.x = center - ARROW_SIZE/2 - 2*HALF_ARROW_PAD;
                break;
            case kRightArrow:
                arrowObj.x = center + ARROW_SIZE + 8*HALF_ARROW_PAD;
                break;
            default:
                break;
        }
    }
}

// array of size 4
- (void)addArrowSequence:(kArrowType[])arrows withSize:(size_t)n withSequenceKey:(NSString *)key
{
    size_t i;
    for (i = 0; i < n; i++) {
        kArrowType arrow = arrows[i];
        NSString *imageName = [NSString stringWithFormat:@"DDR_arrow_blue_%@", [GameData stringForArrow:arrow]];
        GameObject *arrowObj =
            [[GameObject alloc] initWithImageName:imageName
                                                x:0
                                                y:-0.05
                                            width:ARROW_SIZE
                                           height:ARROW_SIZE
                                          visible:YES];
        arrowObj.trajectory = M_PI / 2;
        arrowObj.speed = ARROW_SPEED;
        [self addGameObject:arrowObj forKey:[GameData keyForArrow:arrow withKey:key]];
    }
    [self alignHorizontalArrows:arrows size:n ForKey:key];
}

- (void)addOutlineArrows {
    kArrowType arrows[] = {kLeftArrow, kUpArrow, kDownArrow, kRightArrow};
    size_t i;
    for (i = 0; i < 4; i++) {
        kArrowType arrow = arrows[i];
        NSString *imageName = [NSString stringWithFormat:@"grey_arrow_%@", [GameData stringForArrow:arrow]];
        GameObject *arrowObj =
            [[GameObject alloc] initWithImageName:imageName
                                                x:0
                                                y:0.90
                                            width:ARROW_SIZE
                                           height:ARROW_SIZE
                                          visible:YES];
        arrowObj.speed = 0;
        arrowObj.trajectory = 0;
        arrowObj.opacity = 0.5;
        [self addGameObject:arrowObj forKey:[GameData keyForArrow:arrow withKey:ARROW_OUTLINE_KEY]];
    }
    [self alignHorizontalArrows:arrows size:4 ForKey:ARROW_OUTLINE_KEY];
}

// bottom four bits represent highlighted arrows
// order: xxxx, top bit is left, 0th bit is right
- (void)highlightOutlineArrows:(char)highlights {
    kArrowType arrows[] = {kRightArrow, kUpArrow, kDownArrow, kLeftArrow};
    size_t i;
    for (i = 0; i < 4; i++) {
        kArrowType arrow = arrows[i];
        GameObject *arrowObj = [[self gameObjects] objectForKey:[GameData keyForArrow:arrow withKey:ARROW_OUTLINE_KEY]];
        arrowObj.opacity = ((highlights & 0b1) == 0b1) ? 1 : 0;
        highlights = highlights >> 1;
    }
}

#pragma mark Game Loops

//
// newGame
//
// Temporary code to create test objects for the game.
//
- (void)newGame
{
	[gameObjects removeAllObjects];
    
    [self addOutlineArrows];

    // Generates fake arrow sequence (will be called by delegate method)
    kArrowType arrows[] = {kLeftArrow, kUpArrow, kDownArrow, kRightArrow};
    [self addArrowSequence:arrows withSize:4 withSequenceKey:@"1"];
    
	[self changeRunSelector:@selector(updateLevel:)];
}

//
// updateLevel
//
// Updates the game state
//
- (void)updateLevel:(NSTimer *)aTimer
{
	if (lastUpdate)
	{
		frameDuration = [[NSDate date] timeIntervalSinceDate:lastUpdate];
		lastUpdate = [[NSDate alloc] init];
	}
	else
	{
		frameDuration = GAME_UPDATE_DURATION;
	}
	
	NSArray *allKeys = [gameObjects allKeys];
	for (NSString *gameObjectKey in allKeys)
	{
        NSLog(@"%@",gameObjectKey);
		[gameObjects willChangeValueForKey:gameObjectKey];
		GameObject *gameObject = [gameObjects objectForKey:gameObjectKey];
		if ([gameObject updateWithTimeInterval:frameDuration])
		{
			[gameObjects removeObjectForKey:gameObjectKey];
		}
		[gameObjects didChangeValueForKey:gameObjectKey];
	}
}

//
// startUpdates
//
// Starts the update timer.
//
- (void)startUpdates
{
	lastUpdate = nil;
	
	timer =
		[NSTimer
			scheduledTimerWithTimeInterval:GAME_UPDATE_DURATION
			target:self
			selector:updateSelector
			userInfo:nil
			repeats:YES];
}

//
// stopUpdates
//
// Removes the timer.
//
- (void)stopUpdates
{
	[timer invalidate];
	timer = nil;
}

//
// changeRunSelector:
//
// Switches to a new run loop selector
//
- (void)changeRunSelector:(SEL)newSelector
{
	[self stopUpdates];
	updateSelector = newSelector;
	[self startUpdates];
}

@end
