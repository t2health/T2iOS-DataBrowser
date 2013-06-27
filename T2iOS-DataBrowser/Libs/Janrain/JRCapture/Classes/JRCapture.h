/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright (c) 2012, Janrain, Inc.

 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or
   other materials provided with the distribution.
 * Neither the name of the Janrain, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.


 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 File:   JRCapture.h
 Author: Lilli Szafranski - lilli@janrain.com, lillialexis@gmail.com
 Date:   Tuesday, January 31, 2012
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "JRCaptureTypes.h"
@class JRCaptureUser;

#define engageSigninDialogDidFailToShowWithError engageAuthenticationDialogDidFailToShowWithError
#define engageSigninDidNotComplete engageAuthenticationDidCancel
#define engageSigninDidSucceedForUser engageAuthenticationDidSucceedForUser

#define captureAuthenticationDidSucceedForUser captureSignInDidSucceedForUser
#define captureAuthenticationDidFailWithError captureSignInDidFailWithError

#define JRConventionalSigninNone JRConventionalSignInNone
#define JRConventionalSigninEmailPassword JRConventionalSignInEmailPassword
#define JRConventionalSigninType JRConventionalSignInType

#define startEngageSigninForDelegate startEngageSignInForDelegate

#define startEngageSigninDialogForDelegate startEngageSignInDialogForDelegate
#define startEngageSigninDialogOnProvider startEngageSignInDialogOnProvider
#define startCaptureConventionalSigninForUser startCaptureConventionalSignInForUser
#define startEngageSigninDialogWithConventionalSignin startEngageSignInDialogWithConventionalSignIn
#define withSigninType withSignInType

/**
 * @mainpage Janrain Capture for iOS
 *
 * <a href="http://developers.janrain.com/documentation/mobile-libraries/">
 * The Janrain User Management Platform (JUMP) for iOS</a> makes it easy to include third party authentication
 * <!--and sharing--> in your iPhone or iPad applications.  This Objective-C library includes the same key
 * features as our web version, as well as additional features created specifically for the mobile
 * platform. With Capture integration, you can create, authenticate, and update Capture user records.
 *
 * Your iOS application is unique, and so is the user-specific data you wish to collect. You can customize your Capture
 * instance, by changing your schema, to meet your application’s data needs. JUMP for iOS includes a Perl script which
 * processes your schema and generates Objective-C classes that represent your Capture user model and update themselves
 * on the Capture server.
 *
 * This library enables you to authenticate your users and seamlessly store a wealth of customized data on our
 * cloud-hosted database, both social profile data collected at sign-in as well as the users’ application-specific data
 * collected as they use your application.
 *
 * For directions on doing so, please see <a href="http://TODO">
 *   the Capture for iOS guide</a>
 * on our <a href="http://developers.janrain.com/documentation/mobile-libraries/">developers portal</a>.
 *
 * Before you begin, you need to have created a
 * <a href="https://rpxnow.com/signup_createapp_plus">Janrain Engage application</a>,
 * which you can do on <a href="http://rpxnow.com">http://rpxnow.com</a>
 *
 * Beyond what is needed for Engage for iOS, you will also need:
 *     - A Janrain Capture application, and your Capture APID domain, Capture UI domain, a Client ID, and Capture
 *       entity type name. Contact your deployment engineer for these details.
 *     - Your Capture schema. You can download this from the Capture dashboard, or contact your deployment engineer
 *       for a copy.
 *     - Perl and the JSON-2.53+ module. This is used to generate your Capture user record class structure from your
 *       schema.
 *
 * Some of the code must be generated from your Capture schema. You can easily generate the code yourself, using a
 * script provided with the JUMP library, or the generated code may have been provided to you by your
 * Janrain Deployment Engineer.
 *
 * It is best to <a href="http://TODO">
 *   generate</a> the code before adding the JUMP library to your Xcode project, but, if need be, you can
 * always <a href="http://TODO">
 *   add it later</a>.
 *
 * For an overview of how the library works and how you can take advantage of the library's
 * features, please see the <a href="http://TODO">
 *   Overview</a> section of our documentation.
 *
 * To begin using the SDK, please see the <a href="http://TODO">
 * Capture for iOS guide</a>.
 *
 * For more detailed documentation of the library's API, you can use
 * the <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/index.html">
 *   JREngage API</a> or <a href="http://janrain.github.com/jump.ios/gh_docs/capture/html/index.html">
 *   JRCapture API</a> documentation.
 **/


#import <Foundation/Foundation.h>
#import "JRCaptureObject.h"
#import "JRCaptureUser.h"
#import "JRCaptureUser+Extras.h"
#import "JRCaptureError.h"

/**
 * @file
 * Main API for interacting with the Janrain Capture for iOS library
 *
 * If you wish to include third party authentication <!--and sharing--> in your iPhone or iPad
 * applications, you can use the JRCapture class to achieve this.
 **/

/**
 * Indicates the kind of conventional sign-in to be used.
 **/
typedef enum
{
/**
 * No conventional login dialog added
 **/
 JRConventionalSigninNone = 0,

/**
 * Conventional login dialog added prompting the user for their username and
 * password combination. Use this if your Capture instance is set up to accept a \c username argument when signing in
 * directly to your server
 **/
 JRConventionalSigninUsernamePassword,

/**
 * Conventional login dialog added prompting the user for their email and password
 * combination. Use this if your Capture instance is set up to accept a \c email argument when signing in
 * directly to your server
 **/
 JRConventionalSigninEmailPassword
} JRConventionalSigninType;

/**
 * Indicates the type of the user record as an argument to your
 * JRCaptureSignInDelegate#captureAuthenticationDidSucceedForUser:status: delegate method.
 *
 * There are three possible values for \c captureRecordStatus, indicating the creation state of the record.
 *
 * During Capture authentication, if authenticating through the Engage for iOS portion of the library, the library
 * automatically posts the authentication token to the Capture server. Capture will attempt to sign the user in,
 * using the rich data available from the social identity provider.  One of three results will occur:
 *     - Returning User — The user’s record already exists on the Capture server. The record is retrieved from the
 *       Capture server and passed back to your application.
 *     - New User, Record Automatically Created — The user’s record does not already exist on the Capture server, but
 *       it is automatically created and passed back to your application.  Your application may wish to collect
 *       additional information about the user and push that information back to the Capture server.
 *     - New User, Record Not Automatically Created* — The user’s record was not automatically created, either because
 *       required information was not available in the data returned by the social identity provider, or because auto-
 *       creation was disabled.
 **/
typedef enum
{
/**
 * Indicates that this is a new user and that a new Capture record has already been
 * automatically created. Your application may wish to collect additional new-user information and push that
 * information back to the Capture server
 **/
 JRCaptureRecordNewlyCreated,          /* now it exists, and it is new */

/**
 * Indicates that the user had an existing Capture record and that record has been retrieved.
 * Your application should update its state to reflect the user being signed-in
 **/
 JRCaptureRecordExists,                /* already created, not new */
} JRCaptureRecordStatus;

@class JRActivityObject;

/**
 * @brief
 * Protocol adopted to receive notifications when, and information about, a user that signs in to your application.
 *
 * This protocol will notify the delegate when authentications succeed or fail; it will provide the delegate
 * with the authenticated user's profile data as returned from the Engage and Capture servers.
 **/
@protocol JRCaptureSignInDelegate <NSObject>
@optional
/**
 * @name Configuration
 * Messages sent by JRCapture during dialog launch/configuration of the Engage for iOS portion of the library
 **/
/*@{*/
/**
 * Sent if the application tries to show the Engage for iOS dialog and the dialog failed to show.  May
 * occur if the \c JREngage library failed to configure, or if the dialog is already being displayed, etc.
 *
 * @param error
 *   The error that occurred during configuration. Please see the list of \ref captureErrors "Capture Errors" and
 *   <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/group__engage_errors.html">Engage Errors</a>
 *   for more information
 *
 * @note
 * This message is only sent if your application tries to show a Engage for iOS dialog, and not necessarily
 * when an error occurs, if, say, the error occurred during the library's configuration. The raison d'etre
 * is based on the possibility that your application may preemptively configure Capture and Engage, but never
 * actually use it. If that is the case, then you won't get any error.
 **/
- (void)engageSigninDialogDidFailToShowWithError:(NSError*)error;
/*@}*/

/**
 * @name Authentication
 * Messages sent by JRCapture during authentication
 **/
/*@{*/
/**
 * Sent if the authentication was canceled for any reason other than an error. For example,
 * the user hits the "Cancel" button, any class calls the cancelAuthentication message, or if
 * configuration of the library is taking more than about 16 seconds (rare) to download.
 **/
- (void)engageSigninDidNotComplete;

/**
 * The first message you will receive when Engage authentication has completed with the given provider. At this point,
 * the library will close the dialog and then complete authentication headlessly on Capture. This notification will
 * contain limited data which you can use to update the UI while you wait for Capture to complete authentication.
 *
 * @param engageAuthInfo
 *   An \e NSDictionary of fields containing all the information returned to Janrain Engage from the provider.
 *   Includes the field \c "profile" which contains the user's profile information. This information will be added
 *   to the Capture record once authentication reaches the Capture server.
 *
 * @param provider
 *   The name of the provider on which the user authenticated. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @par Example:
 *   The structure of the auth_info dictionary (represented here in json) should look something like
 *   the following:
 * @code
 "auth_info":
 {
   "profile":
   {
     "displayName": "brian",
     "preferredUsername": "brian",
     "url": "http://brian.myopenid.com/",
     "providerName": "Other",
     "identifier": "http://brian.myopenid.com/"
   }
 }
 * @endcode
 *
 * @sa
 * For a full description of the dictionary and its fields, please see the
 * <a href="http://developers.janrain.com/documentation/api/auth_info/">auth_info response</a>
 * section of the Janrain Engage API documentation.
 *
 * @note
 * The information in the engageAuthInfo dictionary will be added to the Capture record once authentication reaches
 * the Capture server. It is returned at this step for your information only. You do not need to do anything with this
 * data accept perhaps update the UI while your user is waiting for authentication to complete.
 *
 * @note
 * If your user signs in to your server directly (conventional sign-in), this message is not sent to your delegate.
 **/
- (void)engageSigninDidSucceedForUser:(NSDictionary *)engageAuthInfo forProvider:(NSString *)provider;

/**
 * Sent after authentication has successfully reached the Capture server. Capture will attempt to sign the user in,
 * using the rich data available from the provider, and send back a Capture user record and JRCaptureRecordStatus
 * indicating the result. One of three results will occur:
 *       - Returning User — The user’s record already exists on the Capture server. The record is retrieved from the
 *         Capture server and passed back to your application.
 *       - New User, Record Created — The user’s record does not already exist on the Capture server, but it is
 *         automatically created and passed back to your application.  Your application may wish to collect additional
 *         information about the user and push that information back to the Capture server.
 *       - New User, Record Not Created* — The user’s record was not automatically created because required information
 *         that was not available in the data returned by the social identity provider. (For example, your Capture
 *         instance may require an email address, but Twitter does not provide an email address, so the record cannot
 *         be automatically created on Capture when the user signs in with Twitter.)  An incomplete user record is
 *         passed back to your application, where it is your application’s responsibility to collect the missing
 *         required data and invoke the user record creation on Capture.
 *             - Your application should present UI to collect the missing information and any additional information
 *               you wish to collect
 *             - Your application should store this information in the user record object returned by Capture
 *             - Once the information is collected, your application needs to invoke record creation on Capture
 *
 * @param captureUser
 *   An object representing the Capture user, containing the data that was retrieved from this user's record on the
 *   Capture server and including the rich data returned from the social provider.
 *
 * @param captureRecordStatus
 *   A JRCaptureRecordStatus indicating the status of the captureUser record.
 *
 * * If your Capture instance does not require information such as an email address, this scenario should not occur.
 **/
- (void)captureAuthenticationDidSucceedForUser:(JRCaptureUser *)captureUser
                                        status:(JRCaptureRecordStatus)captureRecordStatus;

/**
 * Sent when authentication failed and could not be recovered by the library.
 *
 * @param error
 *   The error that occurred during authentication. Please see the lists of \ref captureErrors "Capture Errors" and
 *   <a href="http://janrain.github.com/jump.ios/gh_docs/engage/html/group__engage_errors.html">Engage Errors</a>
 *   for more information
 *
 * @param provider
 *   The name of the provider on which the user tried to authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @note
 * This message is not sent if authentication was canceled. To be notified of a canceled authentication,
 * see engageSigninDidNotComplete().
 **/
- (void)engageAuthenticationDidFailWithError:(NSError*)error forProvider:(NSString *)provider;

/**
 * Sent when the call to the Capture server has failed.
 *
 * @param error
 *   The error that occurred during Capture authentication. Please see the list of \ref captureErrors "Capture Errors"
 *   for more information
 **/
- (void)captureAuthenticationDidFailWithError:(NSError*)error;

- (void)registerUserDidSucceed:(JRCaptureUser *)registeredUser;

- (void)registerUserDidFailWithError:(NSError *)error;
@end

/**
 * @brief
 * Main API for interacting with the Janrain Capture for iOS library
 *
 * If you wish to include third party authentication in your iPhone or iPad
 * applications, you can use the JRCapture class to achieve this.
 **/
@interface JRCapture : NSObject

/**
 * @name Configuration
 * Configure the library with your Capture and Engage applications
 **/
/*@{*/

/**
 * Set the Backplane channel URL to which Capture will post identity/login messages to. For use with third party
 * integrations
 */
+ (void)setBackplaneChannelUrl:(NSString *)backplaneChannelUrl __unused;

/**
 * Method for configuring the library to work with your Janrain Capture and Engage applications.
 *
 * @param engageAppId
 *   This is your 20-character application ID for Engage. You can find this on your application's Engage Dashboard
 *   on <a href="http://rpxnow.com">http://rpxnow.com</a>. <em>Please do not use your API key. The API key
 *   should never be stored on the device, in code or otherwise.</em>
 *
 * @param captureDomain
 *   The domain of your Capture app instance (e.g., \@"my-name.janraincapture.com")
 *
 * @param captureClientId
 *   This is your 32-character client ID for Capture. You can find this on your Capture Dashboard
 *   on <a href="http://janraincapture.com">https://janraincapture.com/home</a>. <em>Please do not use your client secret.
 *   The client secret should never be stored on the device, in code or otherwise.</em>
 *
 * @param captureLocale
 *   The locale to use when signing-in, from your Capture flow. Required. Follows ISO locale conventions. This locale
 *   must be defined by your Capture flow in its "translations" data structure.
 *
 * @param captureFlowName
 *   The name of the Capture sign-in flow your users will sign-in with. Optional. Pass nil to have Capture use the
 *   flow specified by the default_flow_name setting for your Capture app, specified in the Capture dashboard.
 *
 * @param captureTraditionalSignInFormName
 *   The name of the sign-in form in the Capture flow your users will sign-in with. Required. Likely to be "signinForm"
 *
 * @param captureTraditionalSignInType
 *   The type of traditional sign-in your end-users will sign-in with.
 **/
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
                 captureFlowName:(NSString *)captureFlowName captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
   captureEnableThinRegistration:(BOOL)enableThinRegistration
          captureTraditionalSignInType:(__unused JRConventionalSigninType)captureTraditionalSignInType
captureTraditionalRegistrationFormName:(NSString *)captureTraditionalRegistrationFormName
     captureSocialRegistrationFormName:(NSString *)captureSocialRegistrationFormName
                          captureAppId:(NSString *)captureAppId customIdentityProviders:(NSDictionary *)customProviders;

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
       captureFlowName:(NSString *)captureFlowName
              captureFlowVersion:(NSString *)captureFlowVersion
captureTraditionalSignInFormName:(NSString *)captureSignInFormName
    captureTraditionalSignInType:(__unused JRConventionalSigninType)captureTraditionalSignInType
                    captureAppId:(NSString *)captureAppId customIdentityProviders:(NSDictionary *)customProviders;

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
       captureFlowName:(NSString *)captureFlowName
             captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRConventionalSigninType)captureTraditionalSignInType;

/**
 * @deprecated
 */
+ (void)setEngageAppId:(NSString *)engageAppId captureDomain:(NSString *)captureDomain
       captureClientId:(NSString *)clientId captureLocale:(NSString *)captureLocale
             captureFlowName:(NSString *)captureFlowName captureFormName:(NSString *)captureFormName
captureTraditionalSignInType:(JRConventionalSigninType)captureTraditionalSignInType
     customIdentityProviders:(NSDictionary *)customProviders;

/**
 * Set the Capture access token for an authenticated user
 **/
+ (void)setAccessToken:(NSString *)newAccessToken __unused;

/**
 * Sets the "redirect URI" supplied Capture when registering and signing in.
 *
 * This parameter is used by Capture in the email-verification and password-reset emails sent by Capture.
 */
+ (void)setRedirectUri:(NSString *)redirectUri __unused;
/*@}*/

/**
 * Get the Capture access token
 */
+ (NSString *)getAccessToken __unused;

/**
 * @name Sign in with the Engage for iOS dialogs
 * Methods that initiate sign-in through the Engage for iOS dialogs
 **/
/*@{*/
/**
* Begin authentication. The Engage for iOS portion of the library will
* pop up a modal dialog and take the user through the sign-in process.
*
* @param delegate
*   The JRCaptureSignInDelegate object that wishes to receive messages regarding user authentication
**/
+ (void)startEngageSigninDialogForDelegate:(id<JRCaptureSignInDelegate>)delegate __unused;

/**
 * @deprecated
 */
+ (void)startEngageSignInForDelegate:(id <JRCaptureSignInDelegate>)controller;

/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 **/
+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
                              forDelegate:(id<JRCaptureSignInDelegate>)delegate __unused;

/**
 * Begin authentication. The Engage for iOS portion of the library will
 * pop up a modal dialog and take the user through the sign-in process.
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the
 *   look and feel of the user interface and/or add a native login experience
 **/
+ (void)startEngageSigninDialogWithCustomInterfaceOverrides:(NSDictionary*)customInterfaceOverrides
                                                forDelegate:(id<JRCaptureSignInDelegate>)delegate __unused;

/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the look
 *   and feel of the user interface and/or add a native login experience
 **/
+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
             withCustomInterfaceOverrides:(NSDictionary*)customInterfaceOverrides
                              forDelegate:(id<JRCaptureSignInDelegate>)delegate __unused;


/**
 * Begin authentication for one specific provider. The library will
 * pop up a modal dialog, skipping the list of providers, and take the user straight to the sign-in
 * flow of the passed provider. The user will not be able to return to the list of providers.
 *
 * @param provider
 *   The name of the provider on which the user will authenticate. For a list of possible strings,
 *   please see the \ref authenticationProviders "List of Providers"
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the look
 *   and feel of the user interface and/or add a native login experience
 *
 * @param mergeToken
 *   The merge token, retrieved from the merge flow error instance.
 **/
+ (void)startEngageSigninDialogOnProvider:(NSString *)provider
             withCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                               mergeToken:(NSString *)mergeToken
                              forDelegate:(id <JRCaptureSignInDelegate>)delegate;

/**
 * Begin authentication, adding the option for your users to log directly into Capture through
 * your conventional sign-in mechanism. By using this method to initiate sign-in, the library automatically adds
 * a direct login form, above the list of social providers, that allows your users to login with a username/password
 * or email/password combination.
 *
 * @param conventionalSignInType
 *   A JRConventionalSigninType that tells the library to either prompt the user for their username/password
 *   combination or their email/password combination. This value must match what is configured for your Capture UI
 *   application. If you are unsure which one to use, try one, and if sign-in fails, try the other. If you pass in
 *   JRConventionalSigninNone, this method will do exactly what the startEngageSigninDialogForDelegate:() method does
 *
 * @note
 * Depending on how your Capture application is configured, you pass to this method a
 * JRConventionalSigninType of either JRConventionalSigninUsernamePassword or JRConventionalSigninEmailPassword.
 * Based on this argument, the dialog will prompt your user to either enter their username or email.
 **/
+ (void)startEngageSigninDialogWithConventionalSignin:(JRConventionalSigninType)conventionalSignInType
                                          forDelegate:(id<JRCaptureSignInDelegate>)delegate __unused;
/**
 * Begin authentication, adding the option for your users to log directly into Capture through
 * your conventional signin mechanism. By using this method to initiate sign-in, the library automatically adds
 * a direct login form, above the list of social providers, that allows your users to login with a username/password
 * or email/password combination.
 *
 * @param conventionalSigninType
 *   A JRConventionalSigninType that tells the library to either prompt the user for their username/password
 *   combination or their email/password combination. This value must match what is configured for your Capture UI
 *   application. If you are unsure which one to use, try one, and if sign-in fails, try the other.
 *
 * @param customInterfaceOverrides
 *   A dictionary of objects and properties, indexed by the set of
 *   \link customInterface pre-defined custom interface keys\endlink, to be used by the library to customize the
 *   look and feel of the user interface and/or add a native login experience
 *
 * @note
 * Depending on how your Capture application is configured, you pass to this method a
 * JRConventionalSigninType of either JRConventionalSigninUsernamePassword or JRConventionalSigninEmailPassword.
 * Based on this argument, the dialog will prompt your user to either enter their username or email.
 **/
+ (void)startEngageSigninDialogWithConventionalSignin:(JRConventionalSigninType)conventionalSignInType
                          andCustomInterfaceOverrides:(NSDictionary *)customInterfaceOverrides
                                          forDelegate:(id<JRCaptureSignInDelegate>)delegate;

/**
 * Signs a user in via traditional (username/email and password) authentication on Capture.
 *
 * @param user
 *  The username or the email address
 * @param password
 *  The password
 * @param conventionalSignInType
 *  A JRConventionalSigninType value used to indicate whether the user parameter is a username or an email address
 * @param mergeToken
 *  The Engage token to merge with, retrieved from the merge error
 */
+ (void)startCaptureConventionalSigninForUser:(NSString *)user withPassword:(NSString *)password
                               withSigninType:(JRConventionalSigninType)conventionalSignInType
                                   mergeToken:(NSString *)mergeToken
                                  forDelegate:(id <JRCaptureSignInDelegate>)delegate;

/**
 * Signs a user in via traditional (username/email and password) authentication on Capture.
 *
 * @param user
 *  The username or the email address
 * @param password
 *  The password
 * @param conventionalSignInType
 *  A JRConventionalSigninType value used to indicate whether the user parameter is a username or an email address
 */
+ (void)startCaptureConventionalSigninForUser:(NSString *)user withPassword:(NSString *)password
                               withSigninType:(JRConventionalSigninType)conventionalSignInType
                                  forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused;

///**
// * Refreshes the signed-in user's access token
// */
//+ (void)refreshAccessTokenWithCallback:(void (^)(BOOL, NSError *))callback __unused;

/**
 * Registers a new user.
 *
 * WARNING: Only attributes that are part of the registration form configured in your Capture flow file are set in the
 *          new user's record. Any other attributes (those that are not part of the registration form) will not be set.
 *
 * @param newUser
 *  The user record with which (and in conjunction with your registration form in accordance with the above warning,)
 *  the new user's Capture record will be created.
 * @param socialRegistrationToken
 *  The registration token, used for two-step social registration. The token may be retrieved from the initial (failed)
 *  social sign-in by retrieving it from the JRCaptureError object returned on the event of that same failure.
 *  If nil then a traditional registration is performed, not a social registration.
 * @param delegate
 *  Your JRCaptureSignInDelegate. This delegate will receive callbacks regarding the success or failure of sign-in
 *  events. (A successful registration is considered a sign-in, and results in a valid client-server session.)
 */
+ (void)registerNewUser:(JRCaptureUser *)newUser socialRegistrationToken:(NSString *)socialRegistrationToken
            forDelegate:(id <JRCaptureSignInDelegate>)delegate __unused;

/**
 * Signs the currently-signed-in user, if any, out.
 */
+ (void)clearSignInState __unused;

@end

/**
 * @page Providers
 *
@htmlonly
<!-- Script to resize the iFrames; Only works because iFrames origin is on same domain and iFrame
      code contains script that calls this script -->
<script type="text/javascript">
    function resize(width, height, id) {
        var iframe = document.getElementById(id);
        iframe.width = width;
        iframe.height = height + 50;
        iframe.scrolling = false;
        console.log(width);
        console.log(height);
    }
</script>
@endhtmlonly

@anchor authenticationProviders
@htmlonly
<!-- Redundant attributes to force scrolling to work across multiple browsers -->
<iframe id="basic" src="https://rpxnow.com/docs/mobile_providers?list=basic&device=iphone" width="100%" height="100%"
    style="border:none; overflow:hidden;" frameborder="0" scrolling="no">
  Your browser does not support iFrames.
  <a href="https://rpxnow.com/docs/mobile_providers?list=basic&device=iphone">List of Providers</a>
</iframe></p>
@endhtmlonly

@anchor sharingProviders
@htmlonly
<iframe id="social" src="https://rpxnow.com/docs/mobile_providers?list=social&device=iphone" width="100%" height="100%"
    style="border:none; overflow:hidden;" frameborder="0" scrolling="no">
  Your browser does not support iFrames.
  <a href="https://rpxnow.com/docs/mobile_providers?list=social&device=iphone">List of Social Providers</a>
</iframe></p>
@endhtmlonly
 *
 **/
