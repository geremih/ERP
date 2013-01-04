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
@synthesize html = _html , sessionID =_sessionID , viewWeb = _viewWeb , cookieJar = _cookieJar , myParser = _myParser , userid = _userid, password = _password, answer= _answer, questionid = _questionid , DownloadQueue , ssoToken;


-(NSString *) getTimeTableHTMLForUser:(NSString *) userid password:(NSString *)password andSecretAnswer:(NSString *) answer forQuestion:(NSString *) questionid{
        
    self.userid = userid;
    self.password = password;
    self.answer = answer;
    self.questionid = questionid;
   
    [self getTimetable];

    return self.html;
}

-(void) getTimetable{
    
    NSLog(@"Starting Request");
    [self requestForHomePage];
    
    [self requestForLogin];
    [self requestForWelcomePage];
    [self requestForTimeTable];
    [self requestForTimeTableJSP];
    NSLog(@"Retrung")   ;
        
}



-(void) requestForHomePage{
    
    ASIHTTPRequest * request =  [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/IIT_ERP2"]];
    [request setValidatesSecureCertificate:NO];

    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        self.sessionID = [self getValuefromHTML:response forElement:@"sessionToken"];
        NSLog(@"sessionID is %@ and ssoToken is %@", self.sessionID, self.ssoToken);

        NSLog(@"Loaded HomePage");
    }
    
    
}


-(void) requestForLogin{
    
    NSString *url = @"https://erp.iitkgp.ernet.in/IIT_ERP2/";
    NSString *requestURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    ASIFormDataRequest  * postRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/SSOAdministration/auth.htm"]];
    [postRequest setPostValue:self.userid forKey:@"user_id"];
    [postRequest setPostValue:self.password forKey:@"password"];
    [postRequest setPostValue: self.questionid forKey:@"question_id"];
    [postRequest setPostValue: self.answer forKey:@"answer"];
    [postRequest setPostValue:requestURL forKey:@"requestedUrl"];
    [postRequest setPostValue:self.sessionID forKey:@"sessionToken"];
    [postRequest setPostValue:@"Sign+In" forKey:@"submit"];
    [postRequest setValidatesSecureCertificate:NO];

    [postRequest setRequestMethod:@"POST"];
    [postRequest setDelegate:self];

    [postRequest startSynchronous];
    NSError *error = [postRequest error];

    if (!error) {
        NSString *response = [postRequest responseString];
        
        self.sessionID = [self getValuefromHTML:response forElement:@"sessionToken"];
        self.ssoToken = [self getValuefromHTML:response forElement:@"ssoToken"];
        //NSLog(@"sessionID is %@ and ssoToken is %@", self.sessionID, self.ssoToken);

        NSLog(@"Loaded Login");

        
    }
    
}


-(void) requestForWelcomePage{
    ASIFormDataRequest  * postRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/IIT_ERP2/welcome.jsp"]];
    [postRequest setValidatesSecureCertificate:NO];
    [postRequest setPostValue:self.sessionID forKey:@"sessionToken"];
    
    [postRequest setPostValue:self.ssoToken forKey:@"ssoToken"];
    
    [postRequest setRequestMethod:@"POST"];
    
    [postRequest startSynchronous];
    
    NSError *error = [postRequest error];
    
    if (!error) {
        NSString *response = [postRequest responseString];
        //self.sessionID = [self getValuefromHTML:response forElement:@"sessionToken"];
        //self.ssoToken = [self getValuefromHTML:response forElement:@"ssoToken"];
       // NSLog(@"sessionID is %@ and ssoToken is %@", self.sessionID, self.ssoToken);

        NSLog(@"Loaded Welcome");

        
    }
}

-(void) requestForTimeTable{
     ASIFormDataRequest  * postRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/IIT_ERP2/welcome.jsp"]];
    [postRequest setValidatesSecureCertificate:NO];

    [postRequest setRequestMethod:@"POST"];
    [postRequest setPostValue:@"16" forKey:@"module_id"];

    [postRequest setPostValue:@"40" forKey:@"menu_id"];
    
    [postRequest startSynchronous];

    NSError *error = [postRequest error];

    if (!error) {
        NSString *response = [postRequest responseString];
        
        NSLog(@"Loaded TimeTable");
        //NSLog(@"sessionID is %@ and ssoToken is %@", self.sessionID, self.ssoToken);


        
    }
}




-(void ) requestForTimeTableJSP{
    
   
    
    
    ASIFormDataRequest  * postRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/Acad/student/view_stud_time_table.jsp"]];
    [postRequest setRequestMethod:@"POST"];
    
    [postRequest setPostValue:self.sessionID forKey:@"sessionToken"];
    [postRequest setPostValue:self.ssoToken forKey:@"ssoToken"];

    [postRequest setValidatesSecureCertificate:NO];

    [postRequest startSynchronous];
    
    NSError *error = [postRequest error];
    
    if (!error) {
        NSString *response = [postRequest responseString];
        self.html = response;
        NSLog(@"Loaded TimeTableJSP");

        
        
    }
}





-(NSString *) getValuefromHTML:(NSString *)html forElement:(NSString *)element {
    
    //Values are sessionToken or ssoToken
    
    NSError *error = NULL;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"name=\"%@\" value=\"(.*)\"",element] options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult * result = [regex firstMatchInString:html options:NSMatchingCompleted  range:NSMakeRange(0 , [html length])];
    self.sessionID = [html substringWithRange:[result rangeAtIndex:1]];
    
    return self.sessionID;
}

@end
