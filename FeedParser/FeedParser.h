//
//  FeedParser.h
//  FeedParser
//
//  Created by Andreas Geitmann on 18.11.14.
//  Copyright (c) 2014 simutron IT-Service. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
// iOS code here
    #import <UIKit/UIKit.h>
#else
// OS X code here
    #import <Cocoa/Cocoa.h>
#endif
//! Project version number for FeedParser.
FOUNDATION_EXPORT double FeedParserVersionNumber;

//! Project version string for FeedParser.
FOUNDATION_EXPORT const unsigned char FeedParserVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <FeedParser/PublicHeader.h>


