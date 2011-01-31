//
//  CSCanvasView.h
//  ColorSplate
//
//  Created by endOftime on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const CSBrushSizeUpdateNotification;
extern NSString * const CSBrushColorUpdateNotification;


@interface NSBezierPath (BezierPathQuartzUtilities)

- (CGPathRef)quartzPath;

@end


@interface CSCanvasView : NSView {
	CGFloat brushSize;
	NSColor *currentBrushColor;
	NSPoint origin;
	
	CGMutablePathRef path;
	NSBezierPath *bezierPath;
	
	NSMutableArray *pathArray; 
	NSMutableArray *bezierPathArray; 
	
	NSMutableArray *strokeUndoArray;
	NSMutableArray *bezierStrokeUndoArray;
	
	NSUndoManager *undo ;
	
	CGImageRef currentImage;
	
	
}

@property (retain) NSColor *currentBrushColor;
@property CGFloat brushSize;
@property (retain) NSMutableArray *bezierPathArray; 

-(void)updateBrushSize:(NSNotification *)sender ;
-(void)updateBrushColor:(NSNotification *)sender ;
-(void) undoLastStroke;
-(void) redoLastStroke;
-(void) convertBezierObjectsToCGPathRef:(NSMutableArray *)bz;
-(CGImageRef) getImage;


@end
