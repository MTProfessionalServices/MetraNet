//
//  BillData.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BillData.h"

@implementation BillData

@synthesize Name, Amount;

-(id)initWithName:(NSString*)name amount:(NSString*)amt {
	self.Name = name;
	self.Amount = amt;
	return self;
}

@end
