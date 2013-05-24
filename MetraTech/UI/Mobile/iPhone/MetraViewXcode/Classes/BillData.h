//
//  BillData.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BillData : NSObject {
	NSString *Name;
	NSString *Amount;
}

@property(nonatomic,copy) NSString *Name;
@property(nonatomic, copy) NSString *Amount;

-(id)initWithName:(NSString*)name Amount:(NSString*)amount;

@end
