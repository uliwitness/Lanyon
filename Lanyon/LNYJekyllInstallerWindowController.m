//
//  LNYJekyllInstallerWindowController.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "LNYJekyllInstallerWindowController.h"
#import "NSTask+ULIReadOutput.h"
#import "ULIInputPanelController.h"


@interface LNYJekyllInstallerWindowController ()

@property (strong) IBOutlet NSTextView	*	gemInstallTaskOutputField;
@property (strong) NSTask				*	gemInstallTask;

@end

@implementation LNYJekyllInstallerWindowController

+(NSSet *)keyPathsForValuesAffectingInstallationInProgress
{
	return [NSSet setWithObject: @"gemInstallTask"];
}

+(instancetype)	sharedInstallerWindowController
{
	static LNYJekyllInstallerWindowController	* sSharedController = nil;
	if( !sSharedController )
	{
		sSharedController = [[[self class] alloc] initWithWindowNibName: @"LNYJekyllInstallerWindowController"];
	}
	return sSharedController;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(IBAction)	startGemInstallTask: (id)sender
{
	self.gemInstallTask = [NSTask taskWithLaunchPath: @"/usr/bin/sudo" arguments: @[ @"-S", @"gem", @"install", @"jekyll" ] terminationHandlerWithOutput: ^( NSTask* _Nonnull sender, NSData* _Nonnull output, NSData* _Nonnull errOutput )
	{
		NSLog(@"%@ %@", output, errOutput);
		NSString	*	outputAsString = [[NSString alloc] initWithData: output encoding: NSUTF8StringEncoding];
		[self.gemInstallTaskOutputField performSelectorOnMainThread: @selector(setString:) withObject: outputAsString waitUntilDone: NO];
		[self performSelectorOnMainThread: @selector(concludeInstallation) withObject: nil waitUntilDone: NO];
		NSLog(@"done.");
	}
	progressHandler:^(NSTask * _Nullable sender, NSData * _Nullable output, NSData * _Nullable errOutput)
	{
		NSString	*	outputAsString = nil;
		outputAsString = [[NSString alloc] initWithData: errOutput ? errOutput : output encoding:NSUTF8StringEncoding];
		NSLog(@"%s: %@", (errOutput ? "ERR" : "OUT"), outputAsString);
		if( output )
		{
			[self.gemInstallTaskOutputField.textStorage.mutableString performSelectorOnMainThread: @selector(appendString:) withObject: outputAsString waitUntilDone: NO];
		}
	}];
	
	NSPipe*		inputPipe = [NSPipe pipe];
	self.gemInstallTask.standardInput = inputPipe;
	
	ULIInputPanelController	*	inputPanel = [ULIInputPanelController inputPanelWithPrompt: @"Sudo needs your root password to install a Gem:" answer: @""];
	inputPanel.passwordMode = YES;
	if( [inputPanel runModal] == NSAlertFirstButtonReturn )
	{
		NSString*	password = inputPanel.answerString;
		
		[self.gemInstallTask launch];
		
		[[inputPipe fileHandleForWriting] writeData: [[password stringByAppendingString: @"\n"] dataUsingEncoding: NSUTF8StringEncoding]];
	}
	else
		self.gemInstallTask = nil;
}


-(void)	concludeInstallation
{
	self.installationFinished = YES;
}


-(BOOL)	installationInProgress
{
	return( _gemInstallTask != nil );
}

@end
