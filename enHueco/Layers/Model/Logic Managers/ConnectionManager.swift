//
//  HTTPRequestResponseManager.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Alamofire
import Alamofire_Synchronous

enum HTTPMethod: String
{
    case GET="GET", POST="POST", DELETE="DELETE"
}

struct ConnectionManagerCompoundError: ErrorType
{
    var error: ErrorType?
    var request: NSURLRequest
}

typealias ConnectionManagerSuccessfulRequestBlock = (JSONResponse: AnyObject) -> ()
typealias ConnectionManagerSuccessfulDataRequestBlock = (data: NSData) -> ()
typealias ConnectionManagerFailureRequestBlock = (compoundError: ConnectionManagerCompoundError) -> ()

class ConnectionManager: NSObject
{
    static let completionQueue: NSOperationQueue =
    {
        let queue = NSOperationQueue()
        queue.qualityOfService = .Default
        return queue
    }()

    private static let alamoManager: Alamofire.Manager =
    {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [EHURLS.Domain: .DisableEvaluation]
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }()
    
    class func sendAsyncRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]?, onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        sendAsyncRequest(request, onSuccess: successfulRequestBlock, onFailure: failureRequestBlock)
    }
    
    class func sendAsyncDataRequest(request: NSMutableURLRequest, withJSONParams params:[String : AnyObject]? = nil, onSuccess successfulRequestBlock: ConnectionManagerSuccessfulDataRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        let dictionaryJSONData:NSData? = params != nil ? try! NSJSONSerialization.dataWithJSONObject(params!, options: NSJSONWritingOptions.PrettyPrinted) : nil
        request.HTTPBody = dictionaryJSONData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        alamoManager.request(request).response { (_, response, data, error) -> Void in
            
            completionQueue.addOperationWithBlock
            {
                if let data = data where error == nil
                {
                    print(response?.statusCode)
                    successfulRequestBlock?(data: data)
                }
                else if let error = error
                {
                    print("\(error.code) : \(error)")
                    failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error:error, request:request))
                }
            }
        }
    }
    
    class func sendAsyncRequest(request: NSMutableURLRequest,  onSuccess successfulRequestBlock: ConnectionManagerSuccessfulRequestBlock?, onFailure failureRequestBlock: ConnectionManagerFailureRequestBlock? )
    {
        alamoManager.request(request).responseJSON(options: .MutableContainers) { (response) -> Void in
            
            completionQueue.addOperationWithBlock
            {
                print("Response status: \(response.response?.statusCode) for \(request.URLString)")
                
                guard let value = response.result.value where response.result.isSuccess else
                {
                    print("\(response.result.error?.code) : \(response.result.error)")
                    
                    if let data = response.data { print(NSString(data: data, encoding: NSUTF8StringEncoding)!) }
                    
                    failureRequestBlock?(compoundError: ConnectionManagerCompoundError(error:response.result.error, request:request))
                    return
                }
                
                successfulRequestBlock?(JSONResponse: value)
            }
        }
    }
    
    
    class func sendSyncRequest(request: NSURLRequest) throws -> AnyObject?
    {
        let response = alamoManager.request(request).responseJSON(options: .MutableContainers)
        
        if let error = response.result.error { throw error }
        
        return response.result.value
    }
}

protocol HTTPRequestResponseManagerProtocol
{
    func HTTPRRMPSuccessfulRequestResponse(successBlock: (NSDictionary) -> (), data: NSData)
    func HTTPRRMPUnsuccessfulRequestResponse(error : NSError)
}
