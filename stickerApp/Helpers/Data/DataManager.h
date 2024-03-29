//
//  DataManager.h
//  okjux
//
//  Created by Camila Moscatelli on 11/21/16.
//
//

@interface DataManager : NSObject


#pragma mark User
+ (void)storeUser:(NSString *)userID;
+ (void)storeDeviceToken:(NSString*)token;
+ (void)storeCurrentLocation:(NSArray *)location;
+ (void)storeKarma:(NSString*)karma;

+ (BOOL)userExists;
+ (NSString*)userID;
+ (NSString*)deviceToken;
+ (NSString*)currentLocation;
+ (NSString*)currentLatitud;
+ (NSString*)currentLongitud;
+ (NSInteger)karma;

@end
