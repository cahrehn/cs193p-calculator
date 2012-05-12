//
//  CalculatorBrain.m
//  Calc
//
//  Created by Abdul Jaleel Malik on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain
@synthesize programStack = _programStack;


+ (BOOL)isOperation:(NSString *)operation {

    NSSet *operations = [NSSet setWithObjects:@"+", @"*", @"-", @"/", @"cos", @"sin", @"sqrt", @"π", @"flip", nil];
    return [operations containsObject:operation];
}


+ (int)numberOfOperandsExpected:(NSString *)operation {
    
    NSSet *twoOperandOperations =  [NSSet setWithObjects:@"+", @"*", @"-", @"/", nil];
    NSSet *oneOperandOperations =  [NSSet setWithObjects:@"cos", @"sin", @"sqrt", @"flip", nil];
    NSSet *zeroOperandOperations = [NSSet setWithObjects:@"π", nil];
    
    if([twoOperandOperations containsObject:operation]) return 2;
    else if([oneOperandOperations containsObject:operation]) return 1;
    else if([zeroOperandOperations containsObject:operation]) return 0;
    return -1;
}


- (NSMutableArray *)programStack {

    if(_programStack == nil) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;    
}


- (void)clearMemory {

    [self.programStack removeAllObjects];
}


- (void)pushOperand:(double)operand {

    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (void)popOperand {
    
    if([self.programStack count]) {
        [self.programStack removeLastObject];
    }
}


- (void)pushVariable:(NSString *)variable {
    
    [self.programStack addObject:variable];
}


- (void)pushProgramElement:(id)programElement {
    
    [self.programStack addObject:programElement];
}


- (id)program {
   
    return [self.programStack copy];
}


+ (id)popOperandOffStack:(NSMutableArray *)stack {
    
    id result;
    
    id topOfStack = [stack lastObject];
    if(topOfStack) {
        [stack removeLastObject];
    }
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [NSNumber numberWithDouble:[topOfStack doubleValue]];
    }
    else if([topOfStack isKindOfClass:[NSString class]]) {
        
        NSString *operation = topOfStack;
        
        int numberOperandsExpected = [self numberOfOperandsExpected:operation];
        if(numberOperandsExpected == 2) {
            id secondOperandObject = [self popOperandOffStack:stack];
            id firstOperandObject = [self popOperandOffStack:stack];
            
            if([firstOperandObject isKindOfClass:[NSNumber class]] &&
               [secondOperandObject isKindOfClass:[NSNumber class]]) {
                double firstOperand = [firstOperandObject doubleValue];
                double secondOperand = [secondOperandObject doubleValue];

                // if both are numbers, proceed
                if([operation isEqualToString:@"+"]) {
                    result = [NSNumber numberWithDouble:(firstOperand + secondOperand)];
                }
                else if ([operation isEqualToString:@"*"]) {
                    result = [NSNumber numberWithDouble:(firstOperand * secondOperand)];
                }
                else if ([operation isEqualToString:@"-"]) {
                    double subtrahend = secondOperand;
                    result = [NSNumber numberWithDouble:(firstOperand - subtrahend)];
                }
                else if ([operation isEqualToString:@"/"]) {
                    double divisor = secondOperand;
                    if(divisor) {
                        result = [NSNumber numberWithDouble:(firstOperand / divisor)];
                    }
                    else {
                        result = @"Division by zero";
                    }
                }
            }
            else {
                result = [NSString stringWithFormat:@"%@ needs 2 nums", operation];
            }
        }
        else if(numberOperandsExpected == 1) {
            id nextProgramElement = [self popOperandOffStack:stack];
            double operand;
            if([nextProgramElement isKindOfClass:[NSNumber class]]) {
                operand = [nextProgramElement doubleValue];
                if([operation isEqualToString:@"cos"]) {
                    result = [NSNumber numberWithDouble:cos(operand * M_PI /180)];
                }
                else if([operation isEqualToString:@"sin"]) {
                    result = [NSNumber numberWithDouble:sin(operand * M_PI / 180)];
                }
                else if([operation isEqualToString:@"sqrt"]) {
                    if(operand < 0) {
                        result = @"imaginary";
                    }
                    else {
                        result = [NSNumber numberWithDouble:sqrt(operand)];
                    }
                }
                else if([operation isEqualToString:@"flip"]) {
                    result = [NSNumber numberWithDouble:(-operand)];
                }
            }
            else {
                result = [NSString stringWithFormat:@"%@ w/o operand", operation];
            }
        }
        else if([operation isEqualToString:@"π"]) {
            return [NSNumber numberWithDouble:M_PI];
        }
    }
    
    return result;
}


+ (id)runProgram:(id)program {
    
    NSMutableArray *stack; // = nil not needed in iOS 5
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return [self popOperandOffStack:stack];    
}


+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    
    NSMutableArray *stack; // = nil not needed in iOS 5
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    double variableDouble;
    NSNumber *variableValue;
    
    NSUInteger i;
    for(i = 0; i < stack.count; i++) {
        id variableName = [stack objectAtIndex:i];
        if([variableName isKindOfClass:[NSString class]] && ![self isOperation:variableName]) {

            variableDouble = [[variableValues objectForKey:variableName] doubleValue];
            variableValue = [NSNumber numberWithDouble:variableDouble];
            [stack replaceObjectAtIndex:i withObject:variableValue];
        }
    }
    
    return [self runProgram:stack];
}


+ (NSSet *)variablesUsedInProgram:(id)program {
    
    NSMutableSet *variablesUsedInProgram = [[NSMutableSet alloc] init];
    
    for (id programElement in program) {        
        if([programElement isKindOfClass:[NSString class]] && ![self isOperation:programElement]) {
            [variablesUsedInProgram addObject:programElement];
        }
    }
    
    if([variablesUsedInProgram count]) {
        return [variablesUsedInProgram copy];
    }
    
    return nil;
}


// single operand operations should always have parens
// two operand operations should be in parens if
// the previous operation was multiplication or division and
// the current operation is addition or subtraction
// to reflect proper order of operations
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack 
                       withParens:(BOOL)suggestParens {
    
    id topOfStack = [stack lastObject];
    if(topOfStack) {
        [stack removeLastObject];
    }
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    }
    
    else if([topOfStack isKindOfClass:[NSString class]]) {
        	
        NSString *operation = topOfStack;
        if([self isOperation:operation]) {
            int numberOperandsExpected = [self numberOfOperandsExpected:operation];
            if(numberOperandsExpected == 2) {
                
                NSString *firstOperand, *secondOperand;                
                if([[NSSet setWithObjects:@"*", @"/", nil] containsObject:operation]) {
                    secondOperand = [self descriptionOfTopOfStack:stack withParens:YES];
                    firstOperand = [self descriptionOfTopOfStack:stack withParens:YES];
                }
                else {
                    secondOperand = [self descriptionOfTopOfStack:stack withParens:NO];
                    firstOperand = [self descriptionOfTopOfStack:stack withParens:NO];                    
                }
                
                if([[NSSet setWithObjects:@"+", @"-", nil] containsObject:operation] && suggestParens) {
                    return [NSString stringWithFormat:@"(%@ %@ %@)", firstOperand, operation, secondOperand];	
                }

                return [NSString stringWithFormat:@"%@ %@ %@", firstOperand, operation, secondOperand];                
            }
            else if(numberOperandsExpected == 1) {
                return [NSString stringWithFormat:@"%@(%@)",
                        operation,
                        [self descriptionOfTopOfStack:stack withParens:NO]];
            }
            else if(numberOperandsExpected == 0) {
                return [NSString stringWithFormat:@"%@ ", operation];
            }
            else if(numberOperandsExpected == -1) {
                // something went wrong, descriptionString will be nil
            }
        }
        else { // variable
            return [NSString stringWithFormat:@"%@", operation];
        }
    }
    
    return nil;
}


+ (NSString *)descriptionOfProgram:(id)program {
    
    NSMutableArray *stack; // = nil not needed in iOS 5
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSString *programDescription = [self descriptionOfTopOfStack:stack withParens:NO];
    
    while(stack.count) {
        programDescription = [NSString stringWithFormat:@"%@, %@",
                              programDescription,
                              [self descriptionOfTopOfStack:stack withParens:NO]];
    }
    
    return programDescription;
}

/*
removed because it's annoying and from assignment 1 and
 incompatible with the extra credit in assignment 2
- (double)performOperation:(NSString *)operation {
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}
*/


@end