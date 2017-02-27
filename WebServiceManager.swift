//
//  WebServiceManager.swift
//  WebServiceManager
//
//  Created by Tushar Mohan on 23/02/17.
//  Copyright © 2017 Tushar Mohan. All rights reserved.
//

import UIKit

fileprivate enum ESuccesResponseCodes : Int
{
    case EOk = 200
    case ECreated, EAccepted, ENonAuthoritativeInformation, ENoContent
    
    func description() -> String
    {
        switch self
        {
        case .EOk:
            return "Ok"
        case .ECreated:
            return "Created"
        case .EAccepted:
            return "Accepted"
        case .ENonAuthoritativeInformation:
            return "Non Authoritative Information"
        case .ENoContent:
            return "No Content"
        }
        
    }
}

fileprivate enum EClientErrorCodes : Int
{
    case EBadRequest = 400
    case EUnauthorized, EPaymentRequired, EForbidden, ENotFound
    
    func description() -> String
    {
        switch self
        {
        case .EBadRequest:
            return "Bad Request"
        case .EUnauthorized:
            return "Unauthorized"
        case .EPaymentRequired:
            return "Payment Required"
        case .EForbidden:
            return "Forbidden"
        case .ENotFound:
            return "Not Found"
        }
    }
}

fileprivate struct Constants
{
    static let kWSM_DebugMode       = false
    static let kESCAPED_CHARACTERS  = " \"#%/:<>?@[\\]^`={|}~"
    static let kADDVALUE_TYPE       = "application/json"
}

class WebServiceManager: NSObject
{
    //MARK: - Web Service Utilities
    
    //URL encodes the string and returns the encoded string
    class func createEncodedURL(_ stringToEncode : String) -> String
    {
        let URLCombinedCharacterSet = CharacterSet(charactersIn: Constants.kESCAPED_CHARACTERS).inverted
        
        let escapedString = stringToEncode.addingPercentEncoding(withAllowedCharacters: URLCombinedCharacterSet)!
        
        print(escapedString)
        
        return escapedString
    }
    
    //MARK: - Request Builders
    
    //a generic GET request builder
    class func buildGETRequestWithURL(_ urlString: String) -> URLRequest
    {
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        return request
    }
    
    //a generic POST request builder
    class func buildPOSTRequest(_ urlString: String, requestBody: Dictionary<String, Any>) -> URLRequest
    {
        var request = URLRequest(url: URL(string: urlString)!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60.0 )
        request.addValue(Constants.kADDVALUE_TYPE, forHTTPHeaderField: "Content-Type")
        //request.addValue(Constants.GenericsAndHelpers.kADDVALUE_TYPE, forHTTPHeaderField: "Accept")
        
        do {
            var postBody : Data = try JSONSerialization.data(withJSONObject: requestBody, options:.prettyPrinted)
            request.httpBody = postBody
            
            let contentLength = postBody.count
            
            request.setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
            request.httpMethod = "POST"
        }
        catch
        {
            print(error.localizedDescription)
        }
        return request
    }
    
    //MARK: - Network Call
    
    //Actual call to the service. Returns the data received as a call back
    
    class func sendRequest(_ request : URLRequest, onCompletion handler:@escaping (Data?, Error?) -> Void)
    {
        if Constants.kWSM_DebugMode
        {
            var bodyContent : Any?
            
            if (request.httpBody != nil)
            {
                do
                {
                    bodyContent = try JSONSerialization.jsonObject(with: request.httpBody!, options: JSONSerialization.ReadingOptions(rawValue: UInt(0)))
                }
                catch
                {
                    print(error.localizedDescription)
                }
                
            }
            
            if let bodyContentUnwrapped = bodyContent
            {
                print("Request# \n URL : \(request.url?.absoluteString) Headers : \(request.allHTTPHeaderFields?.description) Request Method: \(request.httpMethod) Post Body : \(bodyContentUnwrapped)")
            }
            else
            {
                print("Request# \n URL : \(request.url?.absoluteString) Headers : \(request.allHTTPHeaderFields?.description) Request Method: \(request.httpMethod) Post Body : <NONE>)")
            }
        }
        URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            
            if let HTTPResponse = response as? HTTPURLResponse
            {
                let statusCode = HTTPResponse.statusCode
                
                if((ESuccesResponseCodes.init(rawValue: statusCode)) != nil)
                {
                    DispatchQueue.main.async
                        {
                            handler(data,error)
                    }
                }
                else if let code = EClientErrorCodes.init(rawValue: statusCode)
                {
                    print("Status Code : \(code)")
                    DispatchQueue.main.async
                        {
                            handler(data,error)
                    }
                }
                else if let errorCaught = error
                {
                    print(response!)
                    print(errorCaught)
                }
            }
            }.resume()
    }
}
