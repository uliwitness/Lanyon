//
//  Document.m
//  Lanyon
//
//  Created by Uli Kusterer on 17/04/16.
//  Copyright © 2016 Uli Kusterer. All rights reserved.
//

#import "LNYJekyllFolderDocument.h"

@interface LNYJekyllFolderDocument ()

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

-(NSString *)	windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"LNYJekyllFolderDocument";
}


-(BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
	return YES;
}


-(BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
	return YES;
}

@end
