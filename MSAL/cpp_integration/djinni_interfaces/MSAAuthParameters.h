// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from configuration.djinni

#import "MSAAuthorizationType.h"
#import <Foundation/Foundation.h>
@class MSAAuthParameters;
@class MSACertificateLocation;
@class MSAUri;


@interface MSAAuthParameters : NSObject

+ (nullable MSAAuthParameters *)getDefault;

- (nullable MSAUri *)getAuthority;

- (void)setAuthority:(nonnull NSString *)authority;

- (nonnull NSString *)getClientId;

- (void)setClientId:(nonnull NSString *)clientId;

- (nullable MSAUri *)getRedirectUri;

- (void)setRedirectUri:(nonnull NSString *)redirectUri;

- (MSAAuthorizationType)getAuthorizationType;

- (void)setAuthorizationType:(MSAAuthorizationType)authorizationType;

- (nonnull NSString *)getAccountId;

- (void)setAccountId:(nonnull NSString *)accountId;

- (nonnull NSString *)getUsername;

- (void)setUsername:(nonnull NSString *)username;

- (nonnull NSString *)getPassword;

- (void)setPassword:(nonnull NSString *)password;

- (nullable MSACertificateLocation *)getCertificateLocation;

- (void)setCertificateLocation:(nullable MSACertificateLocation *)certificateLocation;

- (nonnull NSSet<NSString *> *)getScopes;

- (void)setScopes:(nonnull NSSet<NSString *> *)scopes;

- (BOOL)hasScope:(nonnull NSString *)scope;

- (void)addScope:(nonnull NSString *)scope;

- (int32_t)getBrowserWidth;

- (void)setBrowserWidth:(int32_t)browserWidth;

- (int32_t)getBrowserHeight;

- (void)setBrowserHeight:(int32_t)browserHeight;

- (nonnull NSDictionary<NSString *, NSString *> *)getExtraQueryParameters;

- (void)setExtraQueryParameters:(nonnull NSDictionary<NSString *, NSString *> *)extraQueryParameters;

- (int32_t)getValidationError;

/** Windows settings */
- (int64_t)getBrowserParentHwnd;

- (void)setBrowserParentHwnd:(int64_t)browserParentHwnd;

- (nonnull NSString *)getBrowserWindowTitle;

- (void)setBrowserWindowTitle:(nonnull NSString *)browserWindowTitle;

- (int64_t)getBrowserIconHandle;

- (void)setBrowserIconHandle:(int64_t)browserIconHandle;

@end