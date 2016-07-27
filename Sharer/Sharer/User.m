//
//  User.m
//  Sharer
//
//  Created by 杨桦 on 7/20/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithUserInfo: (FIRUser*) userInfo
               Username: (NSString*) username {
    self = [self init];
    self.userInfo = userInfo;
    self.username = username;
    self.ref = [[FIRDatabase database] reference];
    return self;
}

- (id) initWithEmail: (NSString*) email
               Username: (NSString*) username
                Key:(NSString *)key{
    self = [self init];
    self.email = email;
    self.username = username;
    self.key = key;
    self.ref = [[FIRDatabase database] reference];
    return self;
}

- (id) initWithEmail: (NSString*) email
            Username: (NSString*) username{
    self = [self init];
    self.email = email;
    self.username = username;
    self.ref = [[FIRDatabase database] reference];
    return self;
}

- (id) initWithUserInfo:(FIRUser *)userInfo {
    self = [self init];
    self.userInfo = userInfo;
    self.ref = [[FIRDatabase database] reference];
    [[[[_ref child:@"users"] child:userInfo.uid] child:@"username"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.username = snapshot.value;
        NSLog(@"%@",self.username);
    }];
    return self;
}

- (void) registerUserInfo {
    NSDictionary *newUser = @{@"email": self.userInfo.email,
                           @"username": self.username};
    [[[_ref child:@"users"] child:self.userInfo.uid] setValue: newUser];
    [[[_ref child:@"usersInfo"] childByAutoId] setValue: newUser];
}


//Need to change
- (BOOL) addFriend: (NSString*) email {
    __block BOOL result = NO;
    [[self.ref child:@"usersInfo"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *postDict = snapshot.value;
        NSLog(@"%@",postDict);
        for (NSString* key in postDict) {
            NSDictionary* user = [postDict objectForKey:key];
            if ([[user objectForKey:@"email"] isEqualToString:email]) {
                NSString* email = [user objectForKey:@"email"];
                NSString* username = [user objectForKey:@"username"];
                NSDictionary* friend = @{@"username": username,@"email": email};
                NSString *key = [[[[self.ref child:@"users"] child:self.userInfo.uid] child:@"friends"] childByAutoId].key;
                [[[[[self.ref child:@"users"] child:self.userInfo.uid] child:@"friends" ] child:key] setValue: friend];
                result = YES;
            }
        }
    }];
    
    return YES;
}

@end
