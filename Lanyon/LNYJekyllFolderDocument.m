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

@property (strong) NSTask*	projectCreationTask;
@property (strong) NSTask*	projectBuildTask;

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
		NSString	*	jekyllPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"LNYJekyllPath"];
		NSString	*	projectName = url.lastPathComponent;
		self.projectCreationTask = [NSTask taskWithLaunchPath: jekyllPath arguments: @[@"new", projectName] terminationHandlerWithOutput:^(NSTask * _Nonnull sender, NSData * _Nonnull output, NSData * _Nonnull errOutput)
		{
			NSString*	outputStr = [[NSString alloc] initWithData: output encoding:NSUTF8StringEncoding];
			NSString*	errStr = [[NSString alloc] initWithData: errOutput encoding:NSUTF8StringEncoding];
			NSLog(@"%@\n%@\ndone.", outputStr, errStr);
		} progressHandler: nil];
		NSString	*	dirPath = url.path.stringByDeletingLastPathComponent;
		[self.projectCreationTask setCurrentDirectoryPath: dirPath];
		[self.projectCreationTask launch];
		
		[self.projectCreationTask waitUntilExit];
		self.projectCreationTask = nil;
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
	if( !self.projectBuildTask )
	{
		NSString	*	jekyllPath = [[NSUserDefaults standardUserDefaults] objectForKey: @"LNYJekyllPath"];
		self.projectBuildTask = [NSTask taskWithLaunchPath: jekyllPath arguments: @[@"build"] terminationHandlerWithOutput:^(NSTask * _Nonnull sender, NSData * _Nonnull output, NSData * _Nonnull errOutput)
		{
			NSString*	outputStr = [[NSString alloc] initWithData: output encoding:NSUTF8StringEncoding];
			NSString*	errStr = [[NSString alloc] initWithData: errOutput encoding:NSUTF8StringEncoding];
			NSLog(@"%@\n%@\ndone.", outputStr, errStr);
			self.projectBuildTask = nil;
		} progressHandler: nil];
		NSString	*	dirPath = self.fileURL.path;
		[self.projectBuildTask setCurrentDirectoryPath: dirPath];
		[self.projectBuildTask launch];
	}
}

@end
