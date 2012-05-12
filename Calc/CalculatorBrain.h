//
//  CalculatorBrain.h
//  Calc
//
//  Created by Abdul Jaleel Malik on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
    
@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)popOperand;
- (void)pushVariable:(NSString *)variable;
// - (double)performOperation:(NSString *)operation; // uh, let's call it "deprecated"
- (void)pushProgramElement:(id)programElement;
- (void)clearMemory;

@property (readonly) id program;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end
