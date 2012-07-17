//
//  GraphView.m
//  Calc
//
//  Created by Kenny Linsky on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin = _origin;

#define DEFAULT_SCALE 20
#define DEFAULT_ORIGIN_X self.bounds.origin.x + self.bounds.size.width/2
#define DEFAULT_ORIGIN_Y self.bounds.origin.y + self.bounds.size.height/2

- (CGFloat)scale
{
    if (!_scale) {
        NSNumber *scaleNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"scale"];
        if(!scaleNum) {
            return DEFAULT_SCALE; // don't allow zero scale
        }
        else {
            return [scaleNum floatValue];
        }
    } else {
        return _scale;
    }
}


- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        NSNumber *scaleNumber = [NSNumber numberWithFloat:scale];
        [[NSUserDefaults standardUserDefaults] setObject:scaleNumber forKey:@"scale"];
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}


-(CGPoint)origin {
    if(!_origin.x || !_origin.y) {
        NSNumber *originNumX = [[NSUserDefaults standardUserDefaults] objectForKey:@"originx"];
        NSNumber *originNumY = [[NSUserDefaults standardUserDefaults] objectForKey:@"originy"];
        
        if(!originNumX || !originNumY) {
            _origin.x = DEFAULT_ORIGIN_X;
            _origin.y = DEFAULT_ORIGIN_Y;
        }
        else {
            _origin.x = [originNumX floatValue];
            _origin.y = [originNumY floatValue];
        }
    }
    return _origin;
}


-(void)setOrigin:(CGPoint)origin {
    if(origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        NSNumber *originNumX = [NSNumber numberWithFloat:origin.x];
        NSNumber *originNumY = [NSNumber numberWithFloat:origin.y];
        [[NSUserDefaults standardUserDefaults] setObject:originNumX forKey:@"originx"];
        [[NSUserDefaults standardUserDefaults] setObject:originNumY forKey:@"originy"];
        [self setNeedsDisplay];
    }
}


- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}


- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}	

// Allows edge-to-edge panning
// Panning past the edge simulates a zoom out pinch
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newOrigin = self.origin;
        newOrigin.x += translation.x;
        newOrigin.y += translation.y;
        if(newOrigin.x > 0 && newOrigin.x < self.bounds.size.width &&
           newOrigin.y > 0 && newOrigin.y < self.bounds.size.height) {
            self.origin = newOrigin;
        }
        else {
            float xScale = fabs(translation.x / self.bounds.size.width);
            float yScale = fabs(translation.y / self.bounds.size.height);
            self.scale *= (1 - (xScale + yScale) / 2);
        }
        [gesture setTranslation:CGPointZero inView:self];
    }
}


- (void)moveOrigin:(UITapGestureRecognizer *)gesture {
    self.origin = [gesture locationInView:gesture.view.superview];
}


- (void)drawRect:(CGRect)rect
{
   
    CGPoint midPoint; // center of our bounds in our coordinate system
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    NSArray *dataPoints = [self.dataSource pointsForGraphView:self
                                                       inRect:self.bounds
                                            forNumberOfPoints:self.bounds.size.width
                                                originAtPoint:self.origin
                                                        scale:self.scale];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
    int i;
    
    CGPoint point = [[dataPoints objectAtIndex:0] CGPointValue];
    CGContextMoveToPoint(context, point.x, point.y);
    for(i = 1; i < dataPoints.count; i++) {
        point = [[dataPoints objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);

}


@end
