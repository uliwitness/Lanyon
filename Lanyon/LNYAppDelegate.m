//
//  AppDelegate.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "LNYAppDelegate.h"
#import "ULIFolderDocumentController.h"


@interface LNYAppDelegate ()

@end

@implementation LNYAppDelegate

-(instancetype)	init
{
	self = [super init];
	if( self )
	{
		[ULIFolderDocumentController sharedDocumentController];
	}
	return self;
}

@end
