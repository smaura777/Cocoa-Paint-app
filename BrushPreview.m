//
//  BrushPreview.m
//  ColorSplate
//
//  Created by endOftime on 1/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "BrushPreview.h"

NSString * const CSBrushSizeUpdateNotification    = @"BrushSizeUpdate";
NSString * const CSBrushColorUpdateNotification   = @"BrushColorUpdate";
NSString * const CSCanvasColorUpdateNotification  = @"CanvasColorUpdate";


@implementation BrushPreview

@synthesize brushSize;
@synthesize currentBrushColor;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		//[self setBrushSize:1.0];
		path = [[NSBezierPath alloc] init];
		
		
		currentBrushColor = [NSColor blackColor];
		
    }
    return self;
}



-(void)awakeFromNib {
	
    [paintColor setColor:[NSColor blackColor] ];
	[NSColor setIgnoresAlpha:NO];
	[self setNeedsDisplay:YES];
	NSLog(@"Setting inital colorWell state");
}


- (void)drawRect:(NSRect)dirtyRect {
	
    // Drawing code here.
	NSRect bounds = [self bounds];
	 // Preview canvas background
	[[NSColor whiteColor] set];
	
	[NSBezierPath fillRect:bounds];
	
	
	// Brush color
	[currentBrushColor set];
	
	// alpha component
	NSLog(@"Alpha component is %f",[currentBrushColor alphaComponent]);
	
	[path setLineWidth:brushSize];
	
	NSPoint origin,destination;
	origin.y =  bounds.size.height/2.0;
	origin.x =  10.0;
	[path moveToPoint:origin];
	destination.y = origin.y;
	destination.x = bounds.size.width - 10.0;
	[path 
	 curveToPoint:destination controlPoint1:NSMakePoint(88.0, (CGFloat)bounds.size.height - 10.0) 
	 controlPoint2:NSMakePoint(176.0, 10.0)];
	//[path lineToPoint:destination];
	[path stroke];
	
}


-(IBAction) updateBrushSize:(id)sender {
	 [self setBrushSize:(CGFloat)[sender doubleValue]];
	 [self setNeedsDisplay:YES];
	 NSLog(@" Brush size: %f ",[self brushSize]);
	// send notification
	[[NSNotificationCenter defaultCenter] 
	   postNotificationName:CSBrushSizeUpdateNotification 
	   object:self 
	 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:brushSize] forKey:@"brushSize"]];
	
	NSLog(@"Sending %@ notification",CSBrushSizeUpdateNotification );
	
}
-(IBAction) updateLineSpacing:(id)sender {

}
-(IBAction) updateCanvasBackground:(id)sender {

}
-(IBAction) updatePaintColor:(id)sender {
	[self setCurrentBrushColor:[sender color]];
	[self setNeedsDisplay:YES];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:CSBrushColorUpdateNotification 
	 object:self 
	 userInfo:[NSDictionary dictionaryWithObject:currentBrushColor forKey:@"brushColor"]];
	
	NSLog(@"Sending brush color  %@ notification",CSBrushColorUpdateNotification);
	
	
}




@end
