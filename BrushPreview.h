//
//  BrushPreview.h
//  ColorSplate
//
//  Created by endOftime on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const CSBrushSizeUpdateNotification;
extern NSString * const CSBrushColorUpdateNotification;
extern NSString * const CSCanvasColorUpdateNotification;

@interface BrushPreview : NSView {
	NSBezierPath *path;
	CGFloat brushSize;
	NSColor *currentBrushColor;
	BOOL stroke;
	BOOL fill;
	IBOutlet NSSlider *brushSizeChange;
	IBOutlet NSSlider *lineSpacing;
	IBOutlet NSColorWell *canvasBackground;
	IBOutlet NSColorWell *paintColor;
}

@property  CGFloat brushSize;
@property (retain) NSColor *currentBrushColor;


-(IBAction) updateBrushSize:(id)sender;
-(IBAction) updateLineSpacing:(id)sender;
-(IBAction) updateCanvasBackground:(id)sender;
-(IBAction) updatePaintColor:(id)sender;


@end
