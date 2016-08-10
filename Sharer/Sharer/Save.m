//
//  Save.m
//  Sharer
//
//  Created by 杨桦 on 8/9/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import "Save.h"

@implementation Save

- (id) initWithKey: (NSString*) key
           postKey: (NSString*) postKey {
    self = [self init];
    self.key = key;
    self.postKey = postKey;
    return self;
}

- (id) initWithSnapshot: (FIRDataSnapshot*) snapshot {
    self = [self init];
    self.key = snapshot.key;
    self.postKey = snapshot.value[@"saveID"];
    return self;
}

- (NSDictionary*) getSnapshotValue {
    return @{@"saveID": self.postKey};
}

@end
