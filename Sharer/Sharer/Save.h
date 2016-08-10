//
//  Save.h
//  Sharer
//
//  Created by 杨桦 on 8/9/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"

@interface Save : NSObject

@property (nonatomic) NSString* key;
@property (nonatomic) NSString* postKey;

- (id) initWithKey: (NSString*) key
           postKey: (NSString*) postKey;
- (id) initWithSnapshot: (FIRDataSnapshot*) snapshot;
- (NSDictionary*) getSnapshotValue;
@end
