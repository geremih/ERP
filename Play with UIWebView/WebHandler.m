//
//  WebHandler.m
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/18/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import "WebHandler.h"


@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}
@end


@implementation WebHandler
@synthesize html = _html , sessionID =_sessionID ,requestCount = _requestCount, viewWeb = _viewWeb , cookieJar = _cookieJar , myParser = _myParser , userid = _userid, password = _password, answer= _answer, questionid = _questionid , DownloadQueue;


-(id)init{
    
    self = [super init];
    
    if(self){
        
        self.cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        return self;
    }    
    return nil;
}



-(NSString *) getTimeTableHTMLForUser:(NSString *) userid password:(NSString *)password andSecretAnswer:(NSString *) answer forQuestion:(NSString *) questionid{
        
    self.userid = userid;
    self.password = password;
    self.answer = answer;
    self.questionid = questionid;
    self.DownloadQueue = dispatch_queue_create("htmlData", NULL) ;
    
    self.DownloadQueue = dispatch_queue_create("get secret question", NULL) ;
    
    dispatch_sync( DownloadQueue , ^{
        [self.viewWeb loadRequest:self.requestForHomePage];

        });

    
    
    NSLog(@"Printing html");
    NSLog(self.html);
    return self.html;
}

-(void)dealloc{
    
    dispatch_release(self.DownloadQueue);
  
}

-(NSString *) getHtmlOfCurrentPage {
    
    self.html = [self.viewWeb stringByEvaluatingJavaScriptFromString:
                 @"document.body.innerHTML;"];
    
    return self.html;
}



-(NSString *) getValuefromHTML:(NSString *)html forElement:(NSString *)element {
    
    //Values are sessionToken or ssoToken
    
    NSError *error = NULL;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"name=\"%@\" value=\"(.*)\"",element] options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult * result = [regex firstMatchInString:html options:NSMatchingCompleted  range:NSMakeRange(0 , [html length])];
    self.sessionID = [html substringWithRange:[result rangeAtIndex:1]];
    
    return self.sessionID;
}


-(NSURLRequest *) requestForHomePage{
    
    return  [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/IIT_ERP2"]];
}


-(NSURLRequest *) requestForLogin{
    
    NSString *url = @"https://erp.iitkgp.ernet.in/IIT_ERP2/";
    NSString *requestURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    NSString * postRequestBody = [NSString stringWithFormat:@"user_id=%@&password=%@&question_id=%@&answer=%@&requestedUrl=%@&sessionToken=%@&submit=Sign+In",self.userid, self.password, self.questionid, self.answer, requestURL, self.sessionID];
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/SSOAdministration/auth.htm"]];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                              [self.cookieJar cookies]];
    [postRequest setAllHTTPHeaderFields:headers];
    [postRequest setHTTPBody:[postRequestBody  dataUsingEncoding:NSUTF8StringEncoding]];
    [postRequest setHTTPMethod:@"POST"];
    return postRequest;
    
}

-(NSURLRequest *) requestForTimeTable{
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/IIT_ERP2/welcome.jsp?module_id=16&menu_id=40"]];
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                              [self.cookieJar cookies]];
    [postRequest setAllHTTPHeaderFields:headers];
    [postRequest setHTTPMethod:@"POST"];
    return postRequest;
    
}


-(NSURLRequest *) requestForTimeTableJSP{
    
    NSString * sessionToken = [self getValuefromHTML:self.getHtmlOfCurrentPage forElement:@"sessionToken"];
    
    NSString * ssoToken = [self getValuefromHTML:self.getHtmlOfCurrentPage forElement:@"ssoToken"];
    
    NSString * postRequestBody = [NSString stringWithFormat:@"sessionToken=%@&ssoToken=%@", sessionToken,  ssoToken];
    NSMutableURLRequest * postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/Acad/student/view_stud_time_table.jsp"]];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                              [self.cookieJar cookies]];
    [postRequest setAllHTTPHeaderFields:headers];
    [postRequest setHTTPBody:[postRequestBody  dataUsingEncoding:NSUTF8StringEncoding]];
    [postRequest setHTTPMethod:@"POST"];
    return postRequest;
}


-(void) webViewDidFinishLoad:(UIWebView *)webView   {
    

 
    NSLog(@"%@ %d", webView.request.URL.absoluteString, self.requestCount);
    
    if(self.requestCount ==0){
        self.html = [self getHtmlOfCurrentPage];
        self.sessionID = [self getValuefromHTML:self.html forElement:@"sessionToken"];
        NSLog(@"FIrst request");
        [self.viewWeb loadRequest:self.requestForLogin];
        
    }
    
    
    if(self.requestCount ==2 )
    {
        NSLog(@"second request");
        [self.viewWeb loadRequest:self.requestForTimeTable];
        
    }
    
    if(self.requestCount ==4)
    {
        NSLog(@"3rd request");
        [self.viewWeb loadRequest:self.requestForTimeTableJSP];
        
    }
    
    if(self.requestCount==6)
    {
        self.html =  self.getHtmlOfCurrentPage;
        
        self.myParser = [[Parser alloc] init];
        NSLog(@"Start Parser");
        [self.myParser getTimeTableDictionaryfromHTML:self.html];
        [self.viewWeb removeFromSuperview];
    }
    self.requestCount++;

}


@end
