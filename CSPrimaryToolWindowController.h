//
//  CSPrimaryToolWindowController.h
//  ColorSplate
//
//  Created by endOftime on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CSPrimaryToolWindowController : NSWindowController {
	IBOutlet NSButton *straightLine;
	IBOutlet NSButton *freeDrawing;
	IBOutlet NSButton *ovalDrawing;
	IBOutlet NSButton *rectangleDrawing;
}

-(IBAction) openBrushPanelWindow:(id)sender;
-(IBAction) freeDrawingMode:(id)sender;
-(IBAction) straightLineDrawingMode:(id)sender;
-(IBAction) ovalDrawingMode:(id)sender;
-(IBAction) rectangleDrawingMode:(id)sender;


@end
