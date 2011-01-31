//
//  CSPrimaryToolWindowController.m
//  ColorSplate
//
//  Created by endOftime on 1/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CSPrimaryToolWindowController.h"


@implementation CSPrimaryToolWindowController

-(id) init {
	if ([super initWithWindowNibName:@"PrimaryTool"]){
		return self;
	}
	return nil;	
}

-(void) windowDidLoad {
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

-(IBAction) openBrushPanelWindow:(id)sender {
	NSLog(@"Open brush panel");
}

-(IBAction) freeDrawingMode:(id)sender {
  NSLog(@"Free drawing mode");
}

-(IBAction) straightLineDrawingMode:(id)sender {
  NSLog(@"Straight line mode");
}

-(IBAction) ovalDrawingMode:(id)sender {
   NSLog(@"oval drawing mode");
}

-(IBAction) rectangleDrawingMode:(id)sender {
  NSLog(@"rectangle drawing mode");
}



@end
