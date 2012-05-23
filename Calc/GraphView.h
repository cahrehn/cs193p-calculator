//
//  GraphView.h
//  Calc
//
//  Created by Kenny Linsky on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (NSArray *)pointsForGraphView:(GraphView *)sender
                         inRect:(CGRect)bounds
              forNumberOfPoints:(float)numberOfPoints
                  originAtPoint:(CGPoint)axisOrigin
                          scale:(CGFloat)pointsPerUnit;
@end


@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
@end
