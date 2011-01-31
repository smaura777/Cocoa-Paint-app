//
//  MyDocument.m
//  ColorSplate
//
//  Created by endOftime on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"
#import "CSPrimaryToolWindowController.h"
#import "CSCanvasView.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
       // initialize CSPrimaryToolWindowController
		primaryToolWindow = [[CSPrimaryToolWindowController alloc] init];	
    }
    return self;
}

+ (BOOL)isNativeType:(NSString *)aType
{
	return [[[self class] writableTypes] containsObject:aType];
}


- (BOOL)prepareSavePanel:(NSSavePanel *)sp
{
    // assign defaults for the save panel
    [sp setTitle:@"Save image"];
    [sp setExtensionHidden:NO];
    return YES;
}


+ (NSArray *)writableTypes
{
	return [NSArray arrayWithObjects:@"Impressio Document", @"JPEG File", nil];
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	if (canvas){
		// Show main toolbar window
		[primaryToolWindow showWindow:nil];
		
		if (savedGraphic != nil){
			NSLog(@"Trying to load data in canvas");
			[canvas convertBezierObjectsToCGPathRef:savedGraphic];
		     
		}
		
		NSLog(@"Canvas view is ready");
		
		
	}
	
}

-(NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	
	 
	
	
	if ([typeName isEqualToString:@"Impressio Document"]){
		NSLog(@"Impressio Type of data being written %@",typeName);
	   return [[NSFileWrapper alloc] 
			initRegularFileWithContents:[NSKeyedArchiver archivedDataWithRootObject:[canvas bezierPathArray]]];
	}
	else if ([typeName isEqualToString:@"JPEG File"]) {
		NSData *d;
		// save the image
		// create a mutable data to store the JPEG data into
		CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
		// create an image destination (ImageIO's way of saying we want to save to a file format)
		// note: public.jpeg denotes that we are saving to JPEG
		CGImageDestinationRef ref = CGImageDestinationCreateWithData(data, (CFStringRef)@"public.jpeg", 1, NULL);
		if (ref == NULL)
		{
			printf("problems creating image destination\n");
			if(data)
				CFRelease(data);
			if(ref)
				CFRelease(ref);
			*outError = [NSError errorWithDomain:@"JPEG document errors" code:-10101
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems creating image destination for file save", NSLocalizedDescriptionKey, nil]];
			return nil;
		}
		
		
		CGImageDestinationAddImage(ref, [canvas getImage] , NULL);
		// finalize: this saves the image to the JPEG format as data
		if (!CGImageDestinationFinalize(ref))
		{
			printf("problems writing JPEG file\n");
			CFRelease(data);
			CFRelease(ref);
			*outError = [NSError errorWithDomain:@"Impressio document errors" code:-10102
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"problems writing JPEG file for file save", NSLocalizedDescriptionKey, nil]];
			return nil;
		}
		CFRelease(ref);
		*outError = nil;
		// return the data
		d = (NSData *)data;
		//return [d autorelease];
		return [[NSFileWrapper alloc] initWithSerializedRepresentation:d];
	}
	 
	return nil;
 
}

/**

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
    [[canvas window] endEditingFor:nil];
	
	
	if ([typeName isEqualToString:@"JPEG File"] ){
	  NSLog(@"Type of data being written %@",typeName);
	  return nil;	
	}
	
	return [NSKeyedArchiver archivedDataWithRootObject:[canvas bezierPathArray]];
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

**/


 
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
    NSLog(@"Type of data being read %@",typeName);
	savedGraphic = nil;
	
	@try {
		savedGraphic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
	}
	
	@catch(NSException *e) {
	
     // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
     // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
     if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	 }
      return NO;
		
  }
  
  // For revert operations
	if (canvas != nil){
	  [canvas convertBezierObjectsToCGPathRef:savedGraphic];	
		[canvas setNeedsDisplay:YES];	
		NSLog(@"Revert operation - nib ready");
	}

	return YES;	
	
}

-(void) dealloc {
	[primaryToolWindow release];
	
	[super dealloc];
}

@end
