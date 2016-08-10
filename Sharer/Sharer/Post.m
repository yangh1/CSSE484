//
//  Post.m
//  Sharer
//
//  Created by 杨桦 on 8/2/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import "Post.h"

@implementation Post

- (id) initWithAuthor: (NSString*) author
             Username: (NSString*) username
             PostText: (NSString*) postText
             Location: (NSString*) location {
    self = [self init];
    self.author = author;
    self.username = username;
    self.postText = postText;
    self.location = location;
    return self;
}

- (id) initWithSnapshot: (FIRDataSnapshot*) snapshot {
    self = [self init];
    
    self.key = snapshot.key;
    self.author = snapshot.value[@"author"];
    self.username = snapshot.value[@"username"];
    self.postText = snapshot.value[@"postText"];
    self.location = snapshot.value[@"location"];
    self.images = snapshot.value[@"images"];
    NSLog(@"1111111%@",snapshot.value);
    return self;
}

- (NSDictionary*) getSnapshotValueWithoutImages {
    return @{@"author": self.author,@"username": self.username, @"postText": self.postText, @"location": self.location};
}

- (NSArray*) getImagesUrl {
    return self.images.allValues;
}

@end
