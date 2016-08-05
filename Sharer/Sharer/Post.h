//
//  Post.h
//  Sharer
//
//  Created by 杨桦 on 8/2/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"

@interface Post : NSObject

@property (nonatomic) NSString* key;
@property (nonatomic) NSString* postText;
@property (nonatomic) NSString* author;
@property (nonatomic) NSString* username;
@property (nonatomic) NSString* location;
@property (nonatomic) NSDictionary* images;

- (id) initWithAuthor: (NSString*) author
             PostText: (NSString*) postText
             Location: (NSString*) location;

- (id) initWithSnapshot: (FIRDataSnapshot*) snapshot;

- (FIRDataSnapshot*) getSnapshotValueWithoutImages;

@end
