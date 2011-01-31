//
//  CSCanvasView.m
//  ColorSplate
//
//  Created by endOftime on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSCanvasView.h"
#import "CSPlate_utilities.h"




@implementation NSBezierPath (BezierPathQuartzUtilities)
// This method works only in Mac OS X v10.2 and later.
- (CGPathRef)quartzPath
{
    int i, numElements;
	
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
	
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
		
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
					
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
					
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
										  points[1].x, points[1].y,
										  points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
					
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
		
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
		
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
	
    return immutablePath;
}
@end




@implementation CSCanvasView

@synthesize brushSize;
@synthesize currentBrushColor;
@synthesize bezierPathArray; 


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		
		
    }
    return self;
}




-(void)awakeFromNib {
	
	//path = [[NSBezierPath alloc] init];
	path            = CGPathCreateMutable();
	bezierPath      = [[NSBezierPath alloc] init];
	pathArray       = [[NSMutableArray alloc] init];
	bezierPathArray = [[NSMutableArray alloc] init];
	
	
	
	
	// Adding observers
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self 
		       selector:@selector(updateBrushSize:) 
			   name:CSBrushSizeUpdateNotification
			   object:nil];
	
	[nc addObserver:self 
		   selector:@selector(updateBrushColor:) 
			   name:CSBrushColorUpdateNotification
			 object:nil];
	
	
	NSLog(@"Registered with notification center");
	
	undo = [self undoManager];
	if (undo) {
		NSLog(@"Undo manager initialized");
	}
	
	strokeUndoArray       = [[NSMutableArray alloc] init];
	bezierStrokeUndoArray = [[NSMutableArray alloc] init];

}


-(BOOL)isOpaque {
	return YES;
}

-(void)updateBrushSize:(NSNotification *)sender {
	brushSize = [[[sender userInfo] objectForKey:@"brushSize"] floatValue];
	//NSLog(@"Received notification - new size is %f ",brushSize );
}

-(void)updateBrushColor:(NSNotification *)sender {
   currentBrushColor =  [ [sender userInfo] objectForKey:@"brushColor"] ;

	//NSLog(@"Received color notification for : %@", [currentBrushColor description]);
}




- (void)mouseDragged:(NSEvent *)theEvent {
	
 	NSPoint p = [theEvent locationInWindow];
	origin = [self convertPoint:p fromView:nil];
	
	[bezierPath lineToPoint:origin];
	CGPathAddLineToPoint(path, NULL, origin.x, origin.y);
	[bezierPath closePath];
	CGPathCloseSubpath(path);
	
	[self setNeedsDisplay:YES];
	
	[bezierPath moveToPoint:origin];
	CGPathMoveToPoint(path, NULL, origin.x, origin.y);
	
}

-(void) mouseDown:(NSEvent *)theEvent {
	
	NSPoint p = [theEvent locationInWindow];
	origin = [self convertPoint:p fromView:nil];

	CGPathMoveToPoint(path, NULL, origin.x, origin.y);
	[bezierPath moveToPoint:origin];
	
	NSDictionary *brushSettings = [NSDictionary dictionaryWithObjectsAndKeys:(id)path,@"pathObject",currentBrushColor,@"brushColor",[NSNumber numberWithFloat:brushSize],@"brushSize",nil ];
	
	NSDictionary *bezierBrushSettings = [NSDictionary dictionaryWithObjectsAndKeys:bezierPath,@"pathObject",currentBrushColor,@"brushColor",[NSNumber numberWithFloat:brushSize],@"brushSize",nil ];

	
	
	[pathArray addObject:[brushSettings copyWithZone:NULL]];
	
	[bezierPathArray addObject:[bezierBrushSettings copyWithZone:NULL]];
	
	
	  // Registering undo
	  [[undo prepareWithInvocationTarget:self] undoLastStroke];
	  [undo setActionName:@"last stroke"];
	[[[NSDocumentController sharedDocumentController] currentDocument] updateChangeCount:NSChangeDone];
	
	/**
	
	[[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] 
	  prepareWithInvocationTarget:self] undoLastStroke];
	[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] setActionName:@"Last stroke"];
	
	**/
	
	
	[brushSettings release];
	[bezierBrushSettings release];
	
	// Registering Undo
	
	
	[self setNeedsDisplay:YES];
	
}

-(void)mouseUp:(NSEvent *)theEvent {
    [bezierPath closePath];
	CGPathCloseSubpath(path);
	[self setNeedsDisplay:YES];
	[bezierPath release];
	CGPathRelease(path);
	bezierPath = [[NSBezierPath alloc] init];
	path = CGPathCreateMutable();
	
	//NSLog(@"Mouse UP Event ");
	NSLog(@"Main stroke array count after mouseup %d", [pathArray count]);
	
}


-(void) undoLastStroke {
	if ([pathArray count] > 0){
	  [strokeUndoArray addObject:[pathArray lastObject]]; // Save for redo
	  [pathArray removeLastObject];
	  
		if ([bezierPathArray count] > 0){
		    [bezierStrokeUndoArray addObject:[bezierPathArray lastObject]]; // Save for redo
			[bezierPathArray removeLastObject];  
		   
		}	
	  	
		
	  // Registering undo
	    [[undo prepareWithInvocationTarget:self] redoLastStroke];
	    [undo setActionName:@"last stroke"];
		[undo setActionName:@"last stroke"];
		[[[NSDocumentController sharedDocumentController] currentDocument] updateChangeCount:NSChangeUndone];
		
		/**
		[[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] 
		  prepareWithInvocationTarget:self] redoLastStroke];
		[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] setActionName:@"Last stroke"];
		**/
		
	  [self setNeedsDisplay:YES];
	}
	
	NSLog(@"Main stroke array count after undo %d Main BEZIER stroke array count after undo %d", 
		  [pathArray count],[bezierPathArray count]);
}

-(void) redoLastStroke {
	if ([strokeUndoArray count] > 0){
	  [pathArray addObject:[strokeUndoArray lastObject]]; // Save for redo
	  [strokeUndoArray removeLastObject];
		
		if ([bezierStrokeUndoArray count] > 0){
			[bezierPathArray addObject:[bezierStrokeUndoArray lastObject]]; // Save for redo
			[bezierStrokeUndoArray removeLastObject];
		} 
		
	  // Registering undo
	  [[undo prepareWithInvocationTarget:self] undoLastStroke];
	  [undo setActionName:@"last stroke"];	
	  [[[NSDocumentController sharedDocumentController] currentDocument] updateChangeCount:NSChangeUndone]; 	
	   
		
		/**
		[[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] 
		  prepareWithInvocationTarget:self] undoLastStroke];
		[[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] setActionName:@"Last stroke"];
		**/
		
		
		
	  [self setNeedsDisplay:YES]; 	
	}
	
	NSLog(@"Main stroke array count after redo %d Main BEZIER stroke array count after redo %d", 
		  [pathArray count],[bezierPathArray count]);
}


 






/**

- (void)drawRect:(NSRect)dirtyRect {
	//NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];

    //[NSGraphicsContext saveGraphicsState];
	
	// Drawing code here.
	
	// set background color
	NSRect bounds = [self bounds];
	// Preview canvas background
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	

	

	
	//NSLog(@"Number of objects to draw %d ",[pathArray count]);
	
	//NSBezierPath *newPath;
	
	for (NSDictionary *drawActionsAndSettings in pathArray ){
		if ([self needsToDrawRect:[[drawActionsAndSettings objectForKey:@"pathObject"] bounds]]){
		//newPath = [[NSBezierPath alloc] init]; 
		// [currentContext saveGraphicsState];
		
		
	    //[[drawActionsAndSettings objectForKey:@"pathObject"] setLineWidth:(CGFloat)[[drawActionsAndSettings objectForKey:@"brushSize"] floatValue]];  
		 
		//newPath = [drawActionsAndSettings objectForKey:@"pathObject"];
		[[drawActionsAndSettings objectForKey:@"pathObject"] setLineWidth: (CGFloat)[[drawActionsAndSettings objectForKey:@"brushSize"] floatValue]];
		[[drawActionsAndSettings objectForKey:@"pathObject"] setLineCapStyle:NSRoundLineCapStyle];
		[[drawActionsAndSettings objectForKey:@"pathObject"] setLineJoinStyle:NSRoundLineJoinStyle];
		
		
		//NSLog(@"Brush size set to %f",[[drawActionsAndSettings objectForKey:@"brushSize"] floatValue]);
		
	 
	   // set brush color
	    [[drawActionsAndSettings objectForKey:@"brushColor"] set]; 
	
	   //NSLog(@"Brush color set");
	 
	 
		[[drawActionsAndSettings objectForKey:@"pathObject"] stroke];
		//NSLog(@"Brush actions set");
		
		//[currentContext restoreGraphicsState];
		//[newPath release];
	    //newPath = nil;
		
	   }
		
	}
	 
	
}
**/



- (void)drawRect:(NSRect)dirtyRect {
	CGFloat red,green,blue,alpha;
	//CGFloat colorComponents[4];
	
	
	// set background color
	NSRect bounds = [self bounds];
	// Preview canvas background
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	
	//Bitmap setup
	CGRect myBoundingBox;
	CGImageRef myImage;
	
	myBoundingBox                = CGRectMake(bounds.origin.x, bounds.origin.y, 
							          bounds.size.width, bounds.size.height);
	
	
	CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextRef myBitmapContext = MyCreateBitmapContext(bounds.size.width, 
														 bounds.size.height);
	
	// bitmap drawings
	
	CGContextSetLineCap(myBitmapContext,  kCGLineCapRound);
	CGContextSetLineJoin(myBitmapContext, kCGLineJoinRound);
	
	for (NSDictionary *drawActionsAndSettings in pathArray ){
		
		CGContextSetLineWidth(myBitmapContext, (CGFloat)[[drawActionsAndSettings objectForKey:@"brushSize"] floatValue] );
		
		[[drawActionsAndSettings objectForKey:@"brushColor"] getRed:&red green:&green blue:&blue alpha:&alpha];
		//[[drawActionsAndSettings objectForKey:@"brushColor"] getComponents:colorComponents];
		
		CGContextSetRGBStrokeColor(myBitmapContext, red, green, blue, alpha);
		
		//CGContextSetStrokeColor(myContext,colorComponents);
		
		CGContextAddPath(myBitmapContext, (CGMutablePathRef)[drawActionsAndSettings objectForKey:@"pathObject"]);
		CGContextStrokePath(myBitmapContext);
		
	}
	myImage = CGBitmapContextCreateImage(myBitmapContext);
	CGContextDrawImage(myContext, myBoundingBox,myImage);
	char *bitmapData = CGBitmapContextGetData(myBitmapContext);
	
	/**
	
	CGContextSetLineCap(myContext,  kCGLineCapRound);
	CGContextSetLineJoin(myContext, kCGLineJoinRound);
	
	for (NSDictionary *drawActionsAndSettings in pathArray ){
		
		CGContextSetLineWidth(myContext, (CGFloat)[[drawActionsAndSettings objectForKey:@"brushSize"] floatValue] );
		
		[[drawActionsAndSettings objectForKey:@"brushColor"] getRed:&red green:&green blue:&blue alpha:&alpha];
		//[[drawActionsAndSettings objectForKey:@"brushColor"] getComponents:colorComponents];
		
		CGContextSetRGBStrokeColor(myContext, red, green, blue, alpha);
		
		//CGContextSetStrokeColor(myContext,colorComponents);
		
		CGContextAddPath(myContext, (CGMutablePathRef)[drawActionsAndSettings objectForKey:@"pathObject"]);
		CGContextStrokePath(myContext);
		
	}
	
	**/
	
	CGContextRelease(myBitmapContext);
	if (bitmapData) free(bitmapData);
	
	if (currentImage){
		CGImageRelease(currentImage);
		NSLog(@"cleared current image");
	}
	
	currentImage =  myImage; 
	
	//CGImageRelease(myImage);
	
}


-(void) dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
	CGPathRelease(path);
	[pathArray release];
	[bezierPathArray release];
	[strokeUndoArray release];
	[super dealloc];
}


#pragma mark **** convert bezier  ****

-(void) convertBezierObjectsToCGPathRef:(NSMutableArray *)bz {
	
	if ([bz count ] > 0){
	    for (NSDictionary *dict in bz){
			
			NSDictionary *cgDict = [NSDictionary dictionaryWithObjectsAndKeys:
				(id)[ [dict objectForKey:@"pathObject"] quartzPath],@"pathObject", 
			     [dict objectForKey:@"brushColor"],@"brushColor",
					[dict objectForKey:@"brushSize"],@"brushSize",nil ];
			
			[pathArray addObject: [cgDict retain] ];
			
			[cgDict release];
		   
		}
	}
}



-(CGImageRef) getImage {
	return currentImage;
}




@end
