//
//  GraphViewController.m
//  Calc
//
//  Created by Kenny Linsky on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController

@synthesize functions = _functions;
@synthesize graphView = _graphView;


-(void)setFunctions:(id)functions {
    _functions = functions;
    self.navigationItem.title = [CalculatorBrain descriptionOfProgram:functions];
    if(!self.navigationItem.title) {
        self.navigationItem.title = @"Graph";
    }
    [self.graphView setNeedsDisplay]; // any time our Model changes, redraw our View
}


-(NSArray *)pointsForGraphView:(GraphView *)sender {
    NSMutableArray *points;
    // for each x, calculate y, add CGPoint to *points array    
    return points;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
