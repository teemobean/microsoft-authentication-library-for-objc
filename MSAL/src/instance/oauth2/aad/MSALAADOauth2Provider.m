//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "MSALAADOauth2Provider.h"
#import "MSIDAADV2Oauth2Factory.h"
#import "MSALOauth2Provider+Internal.h"
#import "MSALResult+Internal.h"
#import "MSIDAuthority.h"
#import "MSALAADAuthority.h"
#import "MSIDTokenResult.h"
#import "NSURL+MSIDAADUtils.h"
#import "MSALAccount.h"
#import "MSALAccountId.h"
#import "MSIDAADAuthority.h"
#import "MSIDDefaultTokenCacheAccessor.h"
#import "MSALErrorConverter.h"
#import "MSIDAccountMetadataCacheAccessor.h"
#import "MSALAccount+Internal.h"
#import "MSIDAccountIdentifier.h"

@implementation MSALAADOauth2Provider

#pragma mark - Public

- (MSALResult *)resultWithTokenResult:(MSIDTokenResult *)tokenResult
                                error:(NSError **)error
{
    NSError *authorityError = nil;
    
    MSALAADAuthority *aadAuthority = [[MSALAADAuthority alloc] initWithURL:tokenResult.authority.url error:&authorityError];
    
    if (!aadAuthority)
    {
        MSID_LOG_WITH_CTX_PII(MSIDLogLevelWarning, nil, @"Invalid authority, error %@", MSID_PII_LOG_MASKABLE(authorityError));
        
        if (error) *error = authorityError;
        
        return nil;
    }
    
    return [MSALResult resultWithMSIDTokenResult:tokenResult authority:aadAuthority error:error];
}

- (BOOL)removeAdditionalAccountInfo:(MSALAccount *)account
                              error:(NSError **)error
{
    // If we remove account, we want this app to be also disassociated from foci token, so that user cannot sign in silently again after signing out
    // Therefore, we update app metadata to not have family id for this app after signout
    
    NSURL *authorityURL = [NSURL msidAADURLWithEnvironment:account.environment tenant:account.lookupAccountIdentifier.utid];
    MSIDAADAuthority *aadAuthority = [[MSIDAADAuthority alloc] initWithURL:authorityURL rawTenant:nil context:nil error:nil];
    
    NSError *metadataError = nil;
    BOOL metadataResult = [self.tokenCache updateAppMetadataWithFamilyId:@""
                                                                clientId:self.clientId
                                                               authority:aadAuthority
                                                                 context:nil
                                                                   error:&metadataError];
    
    if (!metadataResult)
    {
        if (error)
        {
            *error = metadataError;
        }
        
        MSID_LOG_WITH_CTX_PII(MSIDLogLevelWarning,nil, @"Failed to update app metadata when removing account %@", MSID_PII_LOG_MASKABLE(metadataError));
        return NO;
    }
    
    return YES;
}

- (MSIDAuthority *)issuerAuthorityWithAccount:(MSALAccount *)account
                             requestAuthority:(MSIDAuthority *)requestAuthority
                                        error:(NSError **)error
{
    if (self.accountMetadataCache)
    {
        NSURL *cachedURL = [self.accountMetadataCache getAuthorityURL:requestAuthority.url
                                                        homeAccountId:account.homeAccountId.identifier
                                                             clientId:self.clientId
                                                              context:nil
                                                                error:error];
        
        MSIDAuthority *cachedAuthority = cachedURL ?
        [[MSIDAADAuthority alloc] initWithURL:cachedURL rawTenant:nil context:nil error:error] :
        requestAuthority;
        
        MSID_LOG_WITH_CTX(MSIDLogLevelInfo, nil, @"Request authority cache look up for %@, using %@ instead", requestAuthority.url, cachedAuthority.url);
        
        return cachedAuthority;
    }
    return requestAuthority;
}

- (BOOL)isSupportedAuthority:(MSIDAuthority *)authority
{
    return [authority isKindOfClass:[MSIDAADAuthority class]];
}

#pragma mark - Protected

- (void)initOauth2Factory
{
    self.msidOauth2Factory = [MSIDAADV2Oauth2Factory new];
}

@end
