//
//  User.h
//  Sharer
//
//  Created by 杨桦 on 7/20/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Firebase.h"

@interface User : NSObject

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *key;
@property (nonatomic) FIRUser *userInfo;
@property (nonatomic) FIRDatabaseReference *ref;

- (id) initWithUserInfo: (FIRUser*) userInfo
            Username: (NSString*) username;
- (id) initWithEmail: (NSString*) email
            Username: (NSString*) username;
- (id) initWithEmail: (NSString*) email
            Username: (NSString*) username
                 Key: (NSString*) key;
- (id) initWithUserInfo:(FIRUser *)userInfo;
- (void) registerUserInfo;
- (BOOL) addFriend: (NSString*) email;
@end
