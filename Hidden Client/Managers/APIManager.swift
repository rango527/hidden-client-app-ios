//
//  APIManager.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

enum APIManager {
    
    // Authenticate
    case login(User)
    case invite([String: Any])
    case logout
    case acceptInvite(InviteCode)
    case sendPasswordRequest(User)
    case changeForgottenPassword(InviteCode)
    
    // Client
    case getShortList(Bool)
    case getShortlistCandidate(String)
    case getCandidateDetails(String, Bool)

    case getProcesses(Bool)
    case getProcessDetails(String, Bool)
    case getProcessSettings(String)
    case getAvailableUsersToAddProcessRole(String, String)
    case getAvailableInterviewersToProcess(String, String)
    case addUsersToProcessRole(String, String, [Int])
    case addUsersToInterview(String, String, [Int])
    case removeUserInProcessRole(String, String, Int)
    case removeUserInInterview(String, String, Int)

    case getProcessTimeline(String)
    case getProcessTimelineShortlistFeedback(String)
    case getProcessTimelineInterview(String, String)
    case voteSubmission(String, [String: Any])
    case submitInterviewProposedDates(String, String)
    case scheduleOrAdvanceToNextStep(String, [String: Any])
    case addInterviewFeedback(String, String, [String: Any])
    case reject(String, [String: Any]?)
    case makeOffer(String, String)
    case suggestStartDate(String, String)
    case getFeedbackOfInterview(String, String)
    case nudgeInterviewFeedback(String, String, String)
    
    case getMessages(String, Bool)
    case sendMessage(String, String)
    
    case getProfile
    case getCandidateList(String)
    case getCompanyDetail
    case updateProfile(User)
    case resetPassword(String, String)
    
    case getDashboard
    case getDashboardTiles(url: String, cache: Bool)
    
    case getJob(String)
    case getJobSettings(String)
    case getAvailableUsersToAddAJobRole(String, String)
    case addUsersToJobRole(String, String, [Int], Bool)
    case removeUserInJobRole(String, String, Int, Bool)

    case getContent(String)
    case getConsentUpdate
    case updateConsent(Consent, String)
}

extension APIManager {
    
    /**
     Endpoint base url and request method
     */
    fileprivate var urlAndMethod: (String, Alamofire.HTTPMethod) {
        #if DEBUG
        let apiBaseURL = Constants.API.development
        #else
        let apiBaseURL = Constants.API.production
        #endif
        
        switch self {
        case .getShortList, .getShortlistCandidate, .getCandidateDetails, .getProcesses, .getProcessSettings, .getAvailableUsersToAddProcessRole, .getAvailableInterviewersToProcess, .getMessages, .getProcessDetails,
             .getProcessTimeline, .getProfile, .getCompanyDetail, .getDashboard, .getDashboardTiles, .getJob, .getJobSettings, .getContent,
             .getProcessTimelineShortlistFeedback, .getProcessTimelineInterview, .getFeedbackOfInterview, .getConsentUpdate, .getCandidateList, .getAvailableUsersToAddAJobRole:
            return (apiBaseURL, .get)
        default:
            return (apiBaseURL, .post)
        }
    }
    
    /**
     Sub Url and parameters / query
     */
    var endPoint: (path: String, params: [String: Any]?) {
        switch self{
        case .login(let user):
            return ("client/login", user.toJSON())
        case .invite(let newMember):
            return ("client/invite", newMember)
        case .logout:
            return ("client/logout", [:])
        case .acceptInvite(let code):
            return ("client/accept-invite", code.toJSON())
        case .sendPasswordRequest(let user):
            return ("client/request-password", user.toJSON())
        case .changeForgottenPassword(let code):
            return ("client/change-forgotten-password", code.toJSON())
            
        case .getShortList:
            return ("client/shortlist", [:])
        case .getShortlistCandidate(let id):
            return ("client/shortlist/\(id)/candidate", [:])
        case .getCandidateDetails(let id, _):
            return ("client/candidates/\(id)", [:])
        case .voteSubmission(let id, let answers):
            return ("client/processes/\(id)/submission-votes", answers)

        case .getProcesses:
            return ("client/processes", [:])
        case .getProcessSettings(let id):
            return ("client/processes/\(id)/settings", [:])
        case .getAvailableUsersToAddProcessRole(let id, let role):
            return ("client/processes/\(id)/roles/\(role)", [:])
        case .getAvailableInterviewersToProcess(let id, let intId):
            return ("client/processes/\(id)/interviews/\(intId)/possible-interviewers", [:])
        case .addUsersToProcessRole(let id, let role, let clients):
            return ("client/processes/\(id)/roles/\(role)/add", ["client_ids": clients])
        case .addUsersToInterview(let id, let intId, let clients):
            return ("client/processes/\(id)/interviews/\(intId)/interviewers/add", ["client_ids": clients])
        case .removeUserInProcessRole(let id, let role, let client):
            return ("client/processes/\(id)/roles/\(role)/remove", ["client_id": client])
        case .removeUserInInterview(let id, let intId, let client):
            return ("client/processes/\(id)/interviews/\(intId)/interviewers/remove", ["client_id": client])
        case .getProcessDetails(let id, _):
            return ("client/processes/\(id)/details", [:])
        case .getProcessTimeline(let id):
            return ("client/processes/\(id)/timeline", [:])

        case .getMessages(let id, _):
            return ("client/conversations/\(id)", [:])
        case .sendMessage(let id, let message):
            return ("client/conversations/\(id)", ["message": message])
        case .submitInterviewProposedDates(let id, let text):
            return ("client/processes/\(id)/interview-dates", ["message": text])
        case .scheduleOrAdvanceToNextStep(let id, let answers):
            return ("client/processes/\(id)/next-step", answers)
        case .addInterviewFeedback(let processId, let feedbackId, let answers):
            //return ("client/processes/\(id)/add-interview-feedback", answers)
            return ("client/processes/\(processId)/feedback/\(feedbackId)", answers)
        case .reject(let id, _):
            return ("client/processes/\(id)/reject", [:])
        case .makeOffer(let id, let message):
            return ("client/processes/\(id)/make-offer", ["message": message])
        case .suggestStartDate(let id, let message):
            return ("client/processes/\(id)/start-dates", ["message": message])
        case .getProcessTimelineShortlistFeedback(let processId):
            return ("client/processes/\(processId)/shortlist-feedback", [:])
        case .getProcessTimelineInterview(let processId, let interviewId):
            return ("client/processes/\(processId)/interviews/\(interviewId)", [:])
        case .getFeedbackOfInterview(let processId, let interviewId):
            return ("client/processes/\(processId)/interviews/\(interviewId)/feedback-answers", [:])
        case .nudgeInterviewFeedback(let processId, let feedbackId, let clientId):
            return ("client/processes/\(processId)/feedback/\(feedbackId)/nudge", ["client_id": clientId])
        case .getProfile:
            return ("client/profile", [:])
        case .getCandidateList(let search):
            return("client/crud/candidate/data", ["search": search])
        case .getCompanyDetail:
            return ("client/profile/company", [:])
        case .resetPassword(let old, let new):
            return ("client/change-password", ["password": old, "new_password": new])
        case .updateProfile(let user):
            return ("client/profile", user.toJSON())

        case .getDashboard:
            return ("client/dashboard", [:])
        case .getDashboardTiles(let url, _):
            return (String(url.dropFirst()), [:])
            
        case .getJob(let id):
            return ("client/jobs/\(id)", [:])
        case .getJobSettings(let id):
            return ("client/jobs/\(id)/settings", [:])
        case .getAvailableUsersToAddAJobRole(let id, let role):
            return ("client/jobs/\(id)/roles/\(role)", [:])
        case .addUsersToJobRole(let id, let role, let clients, let cascade):
            return ("client/jobs/\(id)/roles/\(role)/add", ["client_ids": clients, "cascade": cascade])
        case .removeUserInJobRole(let id, let role, let client, let cascade):
            return ("client/jobs/\(id)/roles/\(role)/remove", ["client_id": client, "cascade": cascade])

        case .getContent(let type):
            return ("content/consent/client/\(type)", [:])
        case .getConsentUpdate:
            return ("client/consent/need-accepting", [:])
        case .updateConsent(let consent, let meta):
            return ("client/consent/update-consent",
                    ["type"     : consent.type?.rawValue.uppercased() ?? "",
                     "version"  : consent.newVersion ?? "",
                     "meta"     : meta])
        }
    }
    
    /**
     Main key value of response
     */
    var keyPath: String? {
        switch self {
        default:
            return nil
        }
    }
    
    var apiVersion: String {
        return "1.0.0"
    }
    
    /**
     Cache Url
     */
    
    var cacheUrl: String {
        switch self{
        default:
            return endPoint.path
        }
    }
    
    var shouldCache: Bool {
        switch self {
        case .getShortList(let isCaching), .getProcesses(let isCaching), .getMessages(_, let isCaching),
             .getDashboardTiles(_, let isCaching), .getCandidateDetails(_, let isCaching), .getProcessDetails(_, let isCaching):
            return isCaching
        case .getProcessTimeline, .getProfile, .getCompanyDetail, .getJob, .getJobSettings, .getContent, .getProcessTimelineShortlistFeedback, .getFeedbackOfInterview:
            return true
        default:
            return false
        }
    }
}

extension APIManager: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        
        let (baseURL, httpMethod) = urlAndMethod
        
        guard let url = URL(string: baseURL + endPoint.path) else {
            fatalError( "[APIManager] URL invalid for \(self)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let token = AppManager.shared.token {
            switch self {
            default:
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        var encodedURLRequest: URLRequest
        let params: [String: Any]? = endPoint.params
        switch httpMethod {
        case .get:
            encodedURLRequest = try URLEncoding.queryString.encode(request as URLRequestConvertible, with: params)
        default:
            encodedURLRequest = try JSONEncoding.default.encode(request as URLRequestConvertible, with: params)
        }
        
        if encodedURLRequest.url != nil {
            print("[APIManager] \(endPoint.path)")
        }
        
        
        return encodedURLRequest
    }
}

extension APIManager {
    
    static func getList<T: Model>(_ r: APIManager) -> Observable<[T]> {
        return Observable.create({ (observer: AnyObserver<[T]>) -> Disposable in
            
            var cachedList: [T]?
            if r.shouldCache {
                cachedList = CacheManager.shared.readList(r)
                if cachedList != nil {
                    observer.onNext(cachedList!)
                }
            }
            
            let request = manager.request(r).responseArray(queue: DispatchQueue.global(), keyPath: r.keyPath, completionHandler: { (response: DataResponse<[T]>) -> Void in
                
                if Constants.API.logEnabled == true, let data = response.data {                
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print("Response \(response.request?.url?.absoluteString ?? "") \(response.response?.statusCode ?? 500): ", json)
                    } catch let error as NSError {
                        print("Error: \(response.request?.url?.absoluteString ?? "")", error)
                    }
                }
                
                if response.result.error != nil {
                    if r.shouldCache != false || cachedList == nil {
                        observer.onError(APIManagerError.error(reason: Constants.Error.server))
                    } else {
                        observer.onCompleted()
                    }
                } else if let value = response.result.value {
                    if r.shouldCache {
                        CacheManager.shared.storeList(value, r: r)
                    }
                    observer.onNext(value)
                    observer.onCompleted()
                } else {
                    observer.onError(APIManagerError.error(reason: Constants.Error.unexpected))
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    static func getObject<T: Model>(_ r: APIManager) -> Observable<T> {
        return Observable.create({ (observer: AnyObserver<T>) -> Disposable in
            var cachedObject: T?
            if r.shouldCache {
                cachedObject = CacheManager.shared.readObject(r)
                if cachedObject != nil {
                    observer.onNext(cachedObject!)
                }
            }
            let request = manager.request(r).responseObject(queue: DispatchQueue.global(), keyPath: r.keyPath, completionHandler: { (response: DataResponse<T>) -> Void in
        
                if Constants.API.logEnabled == true, let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print("Response \(response.request?.url?.absoluteString ?? "") \(response.response?.statusCode ?? 500): ", json)
                    } catch let error as NSError {
                        print("Error: \(response.request?.url?.absoluteString ?? "")", error)
                    }
                }
                
                if response.result.error != nil {
                    if r.shouldCache != false || cachedObject == nil {
                        observer.onError(APIManagerError.error(reason: Constants.Error.server))
                    } else {
                        observer.onCompleted()
                    }
                } else if let value = response.result.value {
                    if r.shouldCache && value.hasError() == false {
                        CacheManager.shared.storeObject(value, r: r)
                    }
                    observer.onNext(value)
                    observer.onCompleted()
                } else {
                    observer.onError(APIManagerError.error(reason: Constants.Error.unexpected))
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
    static func uploadFile<T: Model>(_ url: URL, _ r: APIManager, _ key: String? = nil) -> Observable<T> {
        return Observable.create({ (observer: AnyObserver<T>) -> Disposable in

            var request: DataRequest?
            manager.upload(multipartFormData: { (data) in
                for (key, value) in r.endPoint.params ?? [:] {
                    if let content = "\(value)".data(using: String.Encoding.utf8) {
                        data.append(content, withName: key)
                    }
                }
                data.append(url, withName: key ?? "attachment")
            }, with: r, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    request = upload.responseObject(queue: DispatchQueue.global(), keyPath: r.keyPath, completionHandler: { (response: DataResponse<T>) -> Void in
                        
                        if Constants.API.logEnabled == true, let data = response.data {
                            print("Response: ", String(data: data, encoding: .utf8) ?? "")
                        }
                        
                        if response.result.error != nil {
                            observer.onError(APIManagerError.error(reason: Constants.Error.server))
                        } else if let value = response.result.value {
                            if r.shouldCache && value.hasError() == false {
                                CacheManager.shared.storeObject(value, r: r)
                            }
                            observer.onNext(value)
                            observer.onCompleted()
                        } else {
                            observer.onError(APIManagerError.error(reason: Constants.Error.unexpected))
                            observer.onCompleted()
                        }
                    })
                    return
                case .failure(let error):
                    observer.onError(APIManagerError.error(reason: error.localizedDescription))
                    observer.onCompleted()
                }
            })
            
            return Disposables.create {
                request?.cancel()
            }
        })
    }
    
    
    static var manager: SessionManager = {
        var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        return SessionManager(configuration: configuration)
    }()
}

enum APIManagerError: Error {
    case error(reason: String)
}

extension APIManagerError {
    func message() -> String {
        switch self {
        case .error(let reason):
            return reason
        }
    }
}
