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
	/*
		Skanky hack: We need to install jekyll using sudo. So instead of running it directly,
		we run sudo -S and pass "gem install jekyll" as the parameters. -S means "take the password
		from stdin. So we ask the user for their password and pipe it into sudo.
	*/
	
	self.gemInstallTask = [NSTask taskWithLaunchPath: @"/usr/bin/sudo" arguments: @[ @"-S", @"gem", @"install", @"jekyll" ] terminationHandlerWithOutput: ^( NSTask* _Nonnull sender, NSData* _Nonnull output, NSData* _Nonnull errOutput )
	{
		NSString	*	outputAsString = [[NSString alloc] initWithData: output encoding: NSUTF8StringEncoding];
		NSMutableAttributedString	*	outputAttrStr = [[NSMutableAttributedString alloc] initWithString:outputAsString attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: [NSColor blackColor] }];
		
		outputAsString = [[NSString alloc] initWithData: errOutput encoding: NSUTF8StringEncoding];
		NSAttributedString	*	errOutputAttrStr = [[NSAttributedString alloc] initWithString:outputAsString attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: [NSColor redColor] }];
		[outputAttrStr.mutableString appendString: @"\n\n"];
		[outputAttrStr appendAttributedString: errOutputAttrStr];
		
		[self.gemInstallTaskOutputField.textStorage performSelectorOnMainThread: @selector(setAttributedString:) withObject: outputAttrStr waitUntilDone: NO];
		
		[self performSelectorOnMainThread: @selector(concludeInstallation) withObject: nil waitUntilDone: NO];
	}
	progressHandler:^(NSTask * _Nullable sender, NSData * _Nullable output, NSData * _Nullable errOutput)
	{
		NSString	*	outputAsString = nil;
		outputAsString = [[NSString alloc] initWithData: errOutput ? errOutput : output encoding:NSUTF8StringEncoding];
		NSMutableAttributedString	*	outputAttrStr = [[NSMutableAttributedString alloc] initWithString:outputAsString attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: (output ? [NSColor blackColor] : [NSColor redColor]) }];
		[self.gemInstallTaskOutputField.textStorage performSelectorOnMainThread: @selector(appendAttributedString:) withObject: outputAttrStr waitUntilDone: NO];
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
