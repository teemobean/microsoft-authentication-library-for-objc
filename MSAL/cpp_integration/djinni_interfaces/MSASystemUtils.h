// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from utils.djinni

#import <Foundation/Foundation.h>
@class MSAAuthParameters;
@class MSACertificateLocation;
@class MSALoadClientCertificateResponse;
@class MSASystemInfo;
@class MSAWindowRect;


@protocol MSASystemUtils

- (nonnull NSString *)getCurrentUser;

- (nullable MSAWindowRect *)calculateBrowserRect:(nullable MSAAuthParameters *)authParameters;

- (nonnull NSString *)toLowercase:(nonnull NSString *)input;

- (BOOL)areEqualNoCase:(nonnull NSString *)lhs
                   rhs:(nonnull NSString *)rhs;

- (nullable MSASystemInfo *)getSystemInfo;

- (nullable MSALoadClientCertificateResponse *)loadClientCertificate:(nullable MSACertificateLocation *)certificateLocation;

@end