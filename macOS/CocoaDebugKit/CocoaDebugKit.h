//
//  CocoaDebugKit.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
// iOS code
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for CocoaDebugKit.
FOUNDATION_EXPORT double CocoaDebugFrameworkVersionNumber;

//! Project version string for CocoaDebugKit.
FOUNDATION_EXPORT const unsigned char CocoaDebugFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CocoaDebugKit/PublicHeader.h>

#import "CocoaDebugView.h"
#import "CocoaDebugSettings.h"
#import "CocoaDebugDescription.h"
#import "CocoaPropertyEnumerator.h"
#import "CrossPlatformDefinitions.h"

