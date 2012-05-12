//
//  CalcViewController.h
//  Calc
//
//  Created by Abdul Jaleel Malik on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalcViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *calculationHistoryDisplay;	
@property (weak, nonatomic) IBOutlet UILabel *displayVariablesUsedInProgram;

@end
