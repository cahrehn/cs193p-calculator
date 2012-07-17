//
//  CalcViewController.m
//  Calc
//
//  Created by Abdul Jaleel Malik on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalcViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalcViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) NSDictionary *testVariableValues;
@end

@implementation CalcViewController

@synthesize display = _display;
@synthesize calculationHistoryDisplay = _calculationHistoryDisplay;
@synthesize displayVariablesUsedInProgram = _displayVariablesUsedInProgram;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;


- (CalculatorBrain *) brain {
    
    if(!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}


- (void)updateDisplay {

    id result = [CalculatorBrain runProgram:self.brain.program
                        usingVariableValues:[self testVariableValues]];
    if([result isKindOfClass:[NSNumber class]]) {
        self.display.text = [NSString stringWithFormat:@"%g", [result doubleValue]];
    }
    else if([result isKindOfClass:[NSString class]]) {
        self.display.text = [NSString stringWithFormat:@"%@", result];   
    }
}


- (void)updateHistoryDisplay {
    
    self.calculationHistoryDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}


- (IBAction)makeDecimal:(UIButton *)sender {
    
    NSRange range = [self.display.text rangeOfString:@"."];
    if(range.location == NSNotFound || self.userIsInTheMiddleOfEnteringANumber == NO) {
        [self digitPressed:sender];
    }
}


- (IBAction)variablePressed:(UIButton *)sender {
    
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self.brain pushProgramElement:sender.currentTitle];
    [self updateHistoryDisplay];
}


- (IBAction)digitPressed:(UIButton *)sender {

    NSString *digit = sender.currentTitle;
    if(self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } 
    else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    [self updateHistoryDisplay];
}			


- (IBAction)enterPressed {

    NSNumber *operand = [NSNumber numberWithDouble:[self.display.text doubleValue]];
    [self.brain pushProgramElement:operand];
    self.userIsInTheMiddleOfEnteringANumber = NO;    
    [self updateHistoryDisplay];    
}


- (IBAction)operationPressed:(UIButton *)sender {
    
    if(self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }

    [self.brain pushProgramElement:sender.currentTitle];
    [self updateDisplay];
    [self updateHistoryDisplay];
}


// leftover from Assignment I, untested
// only works while entering a number
- (IBAction)flipSign {

    if(self.userIsInTheMiddleOfEnteringANumber) {
        double flippedValue = -[self.display.text doubleValue];
        self.display.text = [NSString stringWithFormat:@"%g", flippedValue];
    }
    else {
        //double result = [self.brain performOperation:@"flip"];
        //NSString *resultString = [NSString stringWithFormat:@"%g", result];
        //self.display.text = resultString;
    }
    [self updateHistoryDisplay];
}


- (IBAction)undo {
    if(self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:self.display.text.length-1];
        if(self.display.text.length == 0) { // backspaced the whole number
            [self updateDisplay];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
    else {
        [self.brain popOperand];
        [self updateDisplay];
        [self updateHistoryDisplay];        
    }
}

- (IBAction)clearEverything {

    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearMemory];
    [self updateHistoryDisplay];
}


- (IBAction)setTestVariableValuesFromButton:(UIButton *)sender {
    
    if([sender.currentTitle isEqualToString:@"Test 1"]) {
        self.testVariableValues = nil;
    }
    else if([sender.currentTitle isEqualToString:@"Test 2"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"-1", @"x", @"2", @"a", @"5", @"b", nil];
    }
    else if([sender.currentTitle isEqualToString:@"Test 3"]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"2", @"x", @"-3", @"a", @"3", @"b", nil];
    }
    [self updateHistoryDisplay];
    [self updateDisplay];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setFunctions:self.brain.program];
    }
}


- (GraphViewController *)splitViewGraphViewController
{
    id hvc = [self.splitViewController.viewControllers lastObject];
    if(![hvc isKindOfClass:[GraphViewController class]]) {
        hvc = nil;
    }
    return hvc;
}


// if we have a splitViewController (iPad), set its functions to our Calculator Brain's program
// otherwise (iPhone/iPod Touch), perform the ShowGraph segue

- (IBAction)graphTheFunction {
    if([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].functions = self.brain.program;
    }
    else {
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end