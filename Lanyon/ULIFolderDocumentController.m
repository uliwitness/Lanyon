//
//  ULIFolderDocumentController.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "ULIFolderDocumentController.h"

@implementation ULIFolderDocumentController

-(void)openDocument:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:NO];
	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:NO];

	[panel beginWithCompletionHandler: ^( NSInteger result )
	{
		if (result == NSFileHandlingPanelOKButton)
		{
			NSURL* selectedURL = [[panel URLs] objectAtIndex:0];
			NSLog(@"selected URL: %@", selectedURL);
			[self openDocumentWithContentsOfURL: selectedURL
					display: YES
					completionHandler: ^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error)
					{
						NSLog(@"%spened document %@ (%@)", (documentWasAlreadyOpen? "Reo" : "O"), document, error);
					}];
		}
	}];
}

@end
