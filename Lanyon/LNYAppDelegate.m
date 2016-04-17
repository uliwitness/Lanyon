//
//  AppDelegate.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "LNYAppDelegate.h"
#import "ULIFolderDocumentController.h"
#import "LNYJekyllInstallerWindowController.h"


@interface LNYAppDelegate ()

@end

@implementation LNYAppDelegate

-(instancetype)	init
{
	self = [super init];
	if( self )
	{
		[ULIFolderDocumentController sharedDocumentController];
		
		NSDictionary	*	initialDefaults = [NSDictionary dictionaryWithContentsOfURL: [[NSBundle mainBundle] URLForResource: @"LNYInitialDefaults" withExtension: @"plist"]];
		[[NSUserDefaults standardUserDefaults] registerDefaults: initialDefaults];
	}
	return self;
}


-(void)	applicationDidFinishLaunching: (NSNotification *)notification
{
	NSString	*	jekyllPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"LNYJekyllPath"];
	if( ![[NSFileManager defaultManager] fileExistsAtPath: jekyllPath] )
	{
		[[LNYJekyllInstallerWindowController sharedInstallerWindowController] showWindow: self];
	}
}

@end
