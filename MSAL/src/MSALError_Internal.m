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

#import "MSALError_Internal.h"
#import "MSALErrorConverter.h"

NSString *MSALStringForErrorCode(MSALErrorCode code)
{
    switch (code)
    {
        STRING_CASE(MSALErrorInvalidParameter);
        STRING_CASE(MSALErrorInvalidClient);
        STRING_CASE(MSALErrorInvalidGrant);
        STRING_CASE(MSALErrorInvalidScope);
        STRING_CASE(MSALErrorInvalidRequest);
        STRING_CASE(MSALErrorRedirectSchemeNotRegistered);
        STRING_CASE(MSALErrorMismatchedUser);
        STRING_CASE(MSALErrorWrapperCacheFailure);
        STRING_CASE(MSALErrorInteractionRequired);
        STRING_CASE(MSALErrorInvalidResponse);
        STRING_CASE(MSALErrorBadAuthorizationResponse);
        STRING_CASE(MSALErrorAuthorizationFailed);
        STRING_CASE(MSALErrorBadTokenResponse);
        STRING_CASE(MSALErrorNoAuthorizationResponse);
        STRING_CASE(MSALErrorUserCanceled);
        STRING_CASE(MSALErrorSessionCanceled);
        STRING_CASE(MSALErrorInteractiveSessionAlreadyRunning);
        STRING_CASE(MSALErrorInvalidState);
        STRING_CASE(MSALErrorNoViewController);
        STRING_CASE(MSALErrorInternal);
        STRING_CASE(MSALErrorUnhandledResponse);
        STRING_CASE(MSALErrorServerDeclinedScopes);
            
        default:
            return [NSString stringWithFormat:@"Unmapped Error %ld", (long)code];
    }
}

extern void MSALLogError(id<MSIDRequestContext> ctx, NSError *error, const char *function, int line)
{
    NSString *codeString = nil;

    if ([error.domain isEqualToString:MSALErrorDomain])
    {
        codeString = [NSString stringWithFormat:@"Error domain: \"%@\" Code: \"%@\"", error.domain, MSALStringForErrorCode(error.code)];
    }
    else
    {
        codeString = [NSString stringWithFormat:@"Error domain: \"%@\" Code: \"%ld\"", error.domain, (long)error.code];
    }

    NSMutableString *message = [codeString mutableCopy];
    NSMutableString *messagePII = [codeString mutableCopy];

    if (error.userInfo[MSALOAuthErrorKey])
    {
        [message appendFormat:@": {OAuth Error \"%@\" SubError: \"%@\"}", error.userInfo[MSALOAuthErrorKey], error.userInfo[MSALOAuthSubErrorKey]];
        [messagePII appendFormat:@": {OAuth Error \"%@\" SubError: \"%@\" Description:\"%@\"}", error.userInfo[MSALOAuthErrorKey], error.userInfo[MSALOAuthSubErrorKey], error.description];
    }
    else
    {
         [messagePII appendFormat:@": %@", error.description];
    }

    [message appendFormat:@" (%s:%d)", function, line];
    [messagePII appendFormat:@" (%s:%d)", function, line];
    MSID_LOG_ERROR(ctx, @"%@", message);
    MSID_LOG_ERROR_PII(ctx, @"%@", messagePII);
}

NSError *MSALCreateAndLogError(id<MSIDRequestContext> ctx, NSString *domain, NSInteger code, NSString *oauthError, NSString *subError, NSError *underlyingError, NSDictionary *additionalUserInfo, const char *function, int line, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSError *error = [MSALErrorConverter msalErrorFromMsidError:MSIDCreateError(domain, code, description, oauthError, subError, underlyingError, nil, additionalUserInfo)];
    MSALLogError(ctx, error, function, line);
    return error;
}

void MSALFillAndLogError(NSError * __autoreleasing * error, id<MSIDRequestContext> ctx, NSString *domain, NSInteger code, NSString *oauthError, NSString *subError, NSError *underlyingError, NSDictionary *additionalUserInfo, const char *function, int line, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    NSError *msalError = [MSALErrorConverter msalErrorFromMsidError:MSIDCreateError(domain, code, description, oauthError, subError, underlyingError, nil, additionalUserInfo)];
    MSALLogError(ctx, msalError, function, line);
    
    if (error)
    {
        *error = msalError;
    }
}
