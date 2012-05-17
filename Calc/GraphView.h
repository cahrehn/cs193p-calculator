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
- (NSArray *)pointsForGraphView:(GraphView *)sender;
@end


@interface GraphView : UIView
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

@end
