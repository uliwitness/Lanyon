//
//  Document.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "LNYJekyllFolderDocument.h"
#import "NSTask+ULIReadOutput.h"


@interface LNYJekyllFolderDocument ()

@property (strong) IBOutlet NSTextView*		toolOutputField;
@property (strong) NSTask*					projectCreationTask;
@property (strong) NSTask*					projectBuildTask;

@end

@implementation LNYJekyllFolderDocument

-(instancetype)	init
{
    self = [super init];
    if( self )
	{
		// Add your subclass-specific initialization here.
    }
    return self;
}

+(BOOL)	autosavesInPlace
{
	return YES;
}


-(BOOL)	isEntireFileLoaded
{
	return NO;
}

-(NSString *)	windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"LNYJekyllFolderDocument";
}


-(void)	ensureProjectExistsAtURL: (NSURL*)url
{
	if( self.fileURL == nil || ![[NSFileManager defaultManager] fileExistsAtPath: self.fileURL.path] )
	{
		if( !self.projectCreationTask )
		{
			NSAttributedString	*	operationHeadingAttrStr = [[NSAttributedString alloc] initWithString: @"\n========== Initializing new project: ==========\n" attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:0.057 green:0.437 blue:0.192 alpha:1.000] }];
			[self.toolOutputField.textStorage appendAttributedString: operationHeadingAttrStr];
			
			NSString	*	jekyllPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"LNYJekyllPath"];
			NSString	*	projectName = url.lastPathComponent;
			self.projectCreationTask = [NSTask taskWithLaunchPath: jekyllPath arguments: @[@"new", projectName] terminationHandlerWithOutput:^(NSTask * _Nonnull sender, NSData * _Nonnull output, NSData * _Nonnull errOutput)
			{
				
			}
			progressHandler: ^(NSTask * _Nonnull sender, NSData * _Nullable output, NSData * _Nullable errOutput)
			{
				NSString	*	outputAsString = nil;
				outputAsString = [[NSString alloc] initWithData: errOutput ? errOutput : output encoding:NSUTF8StringEncoding];
				NSMutableAttributedString	*	outputAttrStr = [[NSMutableAttributedString alloc] initWithString:outputAsString attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: (output ? [NSColor blackColor] : [NSColor redColor]) }];
				[self.toolOutputField.textStorage performSelectorOnMainThread: @selector(appendAttributedString:) withObject: outputAttrStr waitUntilDone: NO];
			}];
			NSString	*	dirPath = url.path.stringByDeletingLastPathComponent;
			[self.projectCreationTask setCurrentDirectoryPath: dirPath];
			[self.projectCreationTask launch];
			
			[self.projectCreationTask waitUntilExit];
			self.projectCreationTask = nil;
		}
	}
	else
	{
		[[NSFileManager	defaultManager] copyItemAtURL: self.fileURL toURL: url error: nil];
	}
}


-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
	return YES;
}


-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
	[self ensureProjectExistsAtURL: url];
	
	return YES;
}


-(IBAction)	buildProject: (id)sender
{
	if( !self.fileURL )
	{
		[self saveDocumentWithDelegate: self didSaveSelector: @selector(buildProject_Internal) contextInfo: NULL];
	}
	else
		[self buildProject_Internal];
}
	
-(void)	buildProject_Internal
{
	if( !self.projectBuildTask )
	{
		NSAttributedString	*	operationHeadingAttrStr = [[NSAttributedString alloc] initWithString: @"\n========== Building project: ==========\n" attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:0.057 green:0.437 blue:0.192 alpha:1.000] }];
		[self.toolOutputField.textStorage appendAttributedString: operationHeadingAttrStr];
		
		NSString	*	jekyllPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"LNYJekyllPath"];
		self.projectBuildTask = [NSTask taskWithLaunchPath: jekyllPath arguments: @[@"build"] terminationHandlerWithOutput:^(NSTask * _Nonnull sender, NSData * _Nonnull output, NSData * _Nonnull errOutput)
		{
			self.projectBuildTask = nil;
		}
		progressHandler: ^(NSTask * _Nonnull sender, NSData * _Nullable output, NSData * _Nullable errOutput)
		{
			NSString	*	outputAsString = nil;
			outputAsString = [[NSString alloc] initWithData: errOutput ? errOutput : output encoding:NSUTF8StringEncoding];
			NSMutableAttributedString	*	outputAttrStr = [[NSMutableAttributedString alloc] initWithString:outputAsString attributes: @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize: 10.0], NSForegroundColorAttributeName: (output ? [NSColor blackColor] : [NSColor redColor]) }];
			[self.toolOutputField.textStorage performSelectorOnMainThread: @selector(appendAttributedString:) withObject: outputAttrStr waitUntilDone: NO];
		}];
		NSString	*	dirPath = self.fileURL.path;
		[self.projectBuildTask setCurrentDirectoryPath: dirPath];
		[self.projectBuildTask launch];
	}
}


-(IBAction)	revealInFinder: (id)sender
{
	if( !self.fileURL )
	{
		[self saveDocumentWithDelegate: self didSaveSelector: @selector(revealInFinder_Internal) contextInfo: NULL];
	}
	else
		[self revealInFinder_Internal];
}
	
-(void)	revealInFinder_Internal
{
	[[NSWorkspace sharedWorkspace] openURL: self.fileURL];
}

@end
