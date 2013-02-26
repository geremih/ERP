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
@synthesize html = _html , sessionID =_sessionID ,myParser = _myParser , userid = _userid, password = _password, passline = _passline, DownloadQueue , ssoToken,captchaRequested , captchaURL;


-(NSString *) getTimeTableHTMLForUser:(NSString *) userid password:(NSString *)password passline:(NSString *) passline{
    
    self.userid = userid;
    self.password = password;
    self.passline = passline;
    
    
    return     [self getTimetable];

}

-(UIImage *) requestCaptcha{
    captchaRequested = YES;
    [self requestForHomePage];
    
        UIImage * result;
    
        NSData * data = [NSData dataWithContentsOfURL:self.captchaURL];
        result = [UIImage imageWithData:data];
        
        return result;
    
}

-(NSString *) getTimetable{
    
    NSLog(@"Starting Request");
    [self requestForLogin];
    if(![self.html isEqualToString:@"Error"])
    {
    [self requestForWelcomePage];
    [self requestForTimeTable];
    [self requestForTimeTableJSP];
    }
    return self.html;
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
        
        NSError *error = NULL;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"\"PassImageServlet(.*?)\"" options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult * result = [regex firstMatchInString:response options:NSMatchingCompleted  range:NSMakeRange(0 , [response length])];
        NSString * address = [response  substringWithRange:[result rangeAtIndex:1]];
        address = [@"https://erp.iitkgp.ernet.in/SSOAdministration/PassImageServlet" stringByAppendingString:address];
        self.captchaURL =[NSURL URLWithString:address];
        NSLog( address  );
        NSLog(@"Loaded HomePage");
    }
}


-(void) requestForLogin{
    
    NSString *url = @"https://erp.iitkgp.ernet.in/IIT_ERP2/";
    NSString *requestURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    ASIFormDataRequest  * postRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://erp.iitkgp.ernet.in/SSOAdministration/auth.htm"]];
    [postRequest setPostValue:self.userid forKey:@"user_id"];
    [postRequest setPostValue:self.password forKey:@"password"];
    [postRequest setPostValue: self.passline forKey:@"passline"];
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
        
        if ([response  rangeOfString:@"Error in accessing account!"].location == NSNotFound) {
            NSLog(@"Good to go");

        } else {
            NSLog(@"Wrong password");
            self.html=@"Error";
        }
        self.sessionID = [self getValuefromHTML:response forElement:@"sessionToken"];
        self.ssoToken = [self getValuefromHTML:response forElement:@"ssoToken"];
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
        NSLog(@"Loaded TimeTable");
        
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
    NSString * text = [html substringWithRange:[result rangeAtIndex:1]];
    
    return text;
}

@end
