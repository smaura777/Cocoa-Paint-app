//
//  MyDocument.h
//  ColorSplate
//
//  Created by endOftime on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class CSPrimaryToolWindowController;
@class CSCanvasView;

@interface MyDocument : NSDocument
{
	CSPrimaryToolWindowController *primaryToolWindow;
	IBOutlet NSView *canvas;
	NSMutableArray *savedGraphic;
}
@end
