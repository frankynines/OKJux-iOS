//
//  UserServiceManager.h
//  okjux
//
//  Created by TopTier labs on 11/18/16.
//
//

#import <Foundation/Foundation.h>
#import "CommunicationManager.h"
#import "DataManager.h"
#import "Snap.h"

@interface UserServiceManager : NSObject

+ (void)registerUserWith:(NSString*)uuid;

+ (void)getUserSnaps:(NSString*)uuid OnSuccess:(void(^)(NSArray* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

+ (void)createSnap:(NSDictionary *)params Onsuccess:(void(^)(NSDictionary* responseObject))success Onfailure :(void(^)(NSError* error))failure;

+ (void)deleteSnap:(NSInteger)snapID OnSuccess:(void(^)(NSDictionary* responseObject ))success OnFailure :(void(^)(NSError* error))failure;

@end
