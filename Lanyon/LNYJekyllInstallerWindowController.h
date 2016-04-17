//
//  LNYJekyllInstallerWindowController.h
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LNYJekyllInstallerWindowController : NSWindowController

+(instancetype)	sharedInstallerWindowController;

@property (assign) BOOL				installationFinished;	// Successfully OR failed.
@property (readonly,assign) BOOL	installationInProgress;

@end
