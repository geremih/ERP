//
//  WebHandler.h
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/18/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"
@interface WebHandler : NSObject <UIWebViewDelegate>
@property (strong, nonatomic) NSString * html;
@property    (strong, nonatomic) NSString * sessionID;
@property (nonatomic) int requestCount;
@property (weak , nonatomic) IBOutlet UIWebView *viewWeb;
@property (strong, nonatomic) NSHTTPCookieStorage *cookieJar;
@property (strong,nonatomic) Parser * myParser;

@property (nonatomic, strong) NSString * userid;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * answer;
@property (nonatomic, strong) NSString * questionid;
@property (nonatomic) dispatch_queue_t DownloadQueue;

-(NSString *)getHtmlOfCurrentPage;
-(NSString *)getValuefromHTML:(NSString *) html forElement:(NSString *) element;
-(NSURLRequest *) requestForHomePage;
-(NSURLRequest *) requestForLogin;
-(NSURLRequest *) requestForTimeTable;
-(NSURLRequest *) requestForTimeTableJSP;
-(NSString *) getTimeTableHTMLForUser:(NSString *) userid password:(NSString *)password andSecretAnswer:(NSString *) answer forQuestion:(NSString *) questionid;


@end
