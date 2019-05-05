#import "WebService.h"
#import "WebServiceParameter.h"
#import "LFCGzipUtility.h"
#define TimeOut 20

@implementation WebService
{
 @private NSUserDefaults *defaults;
    NSString *server;
}
@synthesize tag;
@synthesize delegate;
@synthesize webServiceUrl;
@synthesize webServiceAction;
@synthesize webServiceParameter;
@synthesize webData;
@synthesize soapResults;
@synthesize webServiceResult;
@synthesize timer;
#pragma mark - initialization

- (id)init
{
    return [self initWithWebServiceAction:nil andDelegate:nil];
}

- (id)initWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    if (self = [super init]) {
        defaults=[NSUserDefaults standardUserDefaults];
        self.delegate = newDelegate;

//        server=@"http://192.168.1.199:6699/Client";
        server=@"https://www.etobaogroup.com:6699/Client";
//        server=@"https://apps.8kk.win:6699/Client";
        [self setWebServiceUrl:server];
        self.webServiceAction = newWebServiceAction;
        self.webData = [[NSMutableData alloc] init];
    }
    
    return self;    
}

+ (id)newWithWebServiceAction:(NSString *)newWebServiceAction andDelegate:(id)newDelegate
{
    return [[WebService alloc] initWithWebServiceAction:newWebServiceAction andDelegate:newDelegate];
}

#pragma mark - WebService

- (void)getWebServiceResult:(NSString *)aWebServiceResult
{
    self.webServiceResult = aWebServiceResult;
    if (timer) [timer invalidate];
        
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TimeOut
                                                  target:self
                                                selector:@selector(timeOut)  
                                                userInfo:nil
                                                 repeats:NO];
    
//    NSMutableString *soapMessage =[[NSMutableString alloc] initWithFormat:
//                                   @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
//                                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
//                                   "<soap:Body>\n"
//                                   "<%@ xmlns=\"http://tempuri.org/\">",webServiceAction];
    
    NSMutableString *soapMessage =[[NSMutableString alloc] initWithFormat:
                                   @"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
                                   "<s:Header><a:Action>http://tempuri.org/IClient/%@</a:Action><a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo><a:To s:mustUnderstand=\"1\">%@</a:To></s:Header>"
                                   "<s:Body>"
                                   "<%@ xmlns=\"http://tempuri.org/\">",webServiceAction,server,webServiceAction];

    for (int i = 0; i < webServiceParameter.count; i++) {
        WebServiceParameter *parmeter = webServiceParameter[i];
        if(NSlog.intValue == 1)
        {
            NSLog([NSString stringWithFormat:@"key:%@ value:%@",parmeter.key==nil?@"":parmeter.key,parmeter.value==nil?@"":parmeter.value]);
            
        }
        [soapMessage appendFormat:@"<%@>%@</%@>", parmeter.key, parmeter.value,parmeter.key];
    }
    [soapMessage appendFormat:@"</%@>"
                                "</s:Body>\n"
                                "</s:Envelope>\n", webServiceAction];

    
    //NSLog(soapMessage);
    NSData *data=[LFCGzipUtility  gzipData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:webServiceUrl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/x-gzip" forHTTPHeaderField:@"Content-Type"];
//    [urlRequest addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
//    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [urlRequest addValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody: data];
    
	//请求
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
	//如果连接已经建好，则初始化data
	if (!theConnection) {
		[self WebServiceGetError:@"The Connection is NULL"];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[webData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self WebServiceGetError:@"The Connection is Error"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    webData=[LFCGzipUtility ungzipData:webData];
    //NSLog([[NSString alloc]initWithData:webData encoding:NSUTF8StringEncoding]);
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:webData];
    [xmlParser setDelegate:self];
	[xmlParser setShouldResolveExternalEntities:YES];
	[xmlParser parse];
}

#pragma mark - WebServiceProtocol

- (void)WebServiceGetCompleted
{    
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    if(NSlog.intValue == 1)
    {
//        NSLog(soapResults);
        
//        DLog(@"%@",soapResults);
        
    }
    if (delegate) {
        if ([delegate respondsToSelector:@selector(WebServiceGetCompleted:)]) {
            [delegate WebServiceGetCompleted:self];
        }
    }
}

- (void)WebServiceGetError:(NSString *)theError
{
    if (timer) {
        [timer invalidate];
        self.timer = nil;
    }
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(WebServiceGetError:error:)])
            [delegate WebServiceGetError:self error:theError];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:webServiceResult]) {
        self.soapResults = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (soapResults) {
		[self.soapResults appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:webServiceResult]) {
        [self WebServiceGetCompleted];
	}
}

#pragma mark - Time Out Manage

- (void)timeOut
{
    [self WebServiceGetError:@"Time Out."];
}

@end
