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


-(void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    self.graphView.dataSource = self;
}


-(NSArray *)pointsForGraphView:(GraphView *)sender
                        inRect:(CGRect)bounds
             forNumberOfPoints:(float)numberOfPoints
                 originAtPoint:(CGPoint)origin
                         scale:(CGFloat)pointsPerUnit;
{

    NSMutableArray *points = [[NSMutableArray alloc] init];
    CGPoint graphPoint;
    float xStart;
    
    // if origin is left of bounds
    // increment until in the bounds?
    
    // if origins is right of bounds
    // decrement until in the bounds?
    	
    if (CGRectContainsPoint(bounds, origin)) {
        xStart = -origin.x/pointsPerUnit;
    }
  
    float increment = 1 / pointsPerUnit;
    float xEnd = xStart + increment * numberOfPoints;
    
    for(float i = 0; xStart + i < xEnd; i+=increment) {
        
        NSString *xValue = [NSString stringWithFormat:@"%g", xStart + i];
        NSDictionary *variableValue = [NSDictionary dictionaryWithObjectsAndKeys:xValue, @"x", nil];
        id result = [CalculatorBrain runProgram:self.functions
                            usingVariableValues:variableValue];
        if([result isKindOfClass:[NSNumber class]]) {
            graphPoint.y = origin.y - [result doubleValue] * pointsPerUnit;
        }
        else {
            graphPoint.y = 0;
        }
        graphPoint.x = i * pointsPerUnit;
        [points addObject:[NSValue valueWithCGPoint:graphPoint]];
    }

    return points;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
