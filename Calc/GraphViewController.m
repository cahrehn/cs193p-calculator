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
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@end

@interface GraphViewController () <SplitViewBarButtonItemPresenter>
@end

@implementation GraphViewController

@synthesize functions = _functions;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarBUttonItem;


-(void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}


 -(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarBUttonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if(_splitViewBarBUttonItem) [toolbarItems removeObject:_splitViewBarBUttonItem];
        if(splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarBUttonItem = splitViewBarButtonItem;
    }
}


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
    // enable pinch gestures in the GraphView using its pinch: handler
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]
                                          initWithTarget:self.graphView action:@selector
                                          (pinch:)]];
    // recognize a pan gesture and modify our Model
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                          initWithTarget:self.graphView action:@selector
                                          (pan:)]];
    // recognize a triple tap gesture
    UITapGestureRecognizer *moveOrigin = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self.graphView action:@selector
                                          (moveOrigin:)];
    moveOrigin.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:moveOrigin];
    
    self.graphView.dataSource = self;
}

- (IBAction)reorient {
    [self.graphView setScale:20];
    CGPoint originalOrigin;
    originalOrigin.x = self.graphView.bounds.size.width/2;
    originalOrigin.y = self.graphView.bounds.size.height/2;
    [self.graphView setOrigin:originalOrigin];    
    
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
        id result;
        
        if([[CalculatorBrain variablesUsedInProgram:self.functions] count] > 0) {
            result = [CalculatorBrain runProgram:self.functions
                                usingVariableValues:variableValue];
        }
        else {
            result = [CalculatorBrain runProgram:self.functions];
        }
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


-(id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if(![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}


-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}


 -(void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
 {
     barButtonItem.title = @"Calc";
     [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;

 } 


-(void)splitViewController:(UISplitViewController *)svc
    willShowViewController:(UIViewController *)aViewController
 invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
