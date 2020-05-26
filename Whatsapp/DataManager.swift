//
//  DataManager.swift
//  Synnovation
//
//  Created by Synechron on 04/11/15.
//  Copyright © 2015 Synechron. All rights reserved.
//


import Foundation


//
//  AddressHandler.swift
//  Adress Sender
//
//  Created by Synechron on 28/10/15.
//  Copyright © 2015 Synechron. All rights reserved.
//

import UIKit


let     ERROR_CODE_PARA_MISSING                             = 1
let     ERROR_CODE_TIMED_OUT                                = 2
let     ERROR_CODE_WRONG_CREDENTIALS                        = 3
let     ERROR_CODE_UNABLE_TO_DOWNLOAD                       = 4
let     ERROR_CODE_UNABLE_TO_PARSE                          = 5


let     APP_USERNAME_KEY                                    = "SynnovationUserAppUserName"
let     APP_PASSWORD_KEY                                    = "SynnovationUserAppPassword"
let     APP_USERID_KEY                                      = "SynnovationUserAppUserId"


let     USER_FILES_PATH                                     = "UserFiles"


let     TABLECELL_COLOR                                     = UIColor(red: 1, green:1, blue: 0.8, alpha: 1)


typealias MyClosure = (data: AnyObject?, response: NSURLResponse?, msgError: NSError?) -> Void
typealias onDataDownLoadComplete = (msgError: NSError?) -> Void



@objc class DataManager : NSObject {
    
    private static let sharedInstance = DataManager()
    
    
    
    
    private var appFileManager = NSFileManager.defaultManager()
    
    // METHODS
    private override init() {
        
    }
    
    class func downLoadTheJsonData(){
    }
    
//    class func getTheUserName() -> String{
//        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        
//        var userName : String
////        userName = userDefaults.objectForKey(USERNAME) as! String
//        
//        return userName
//        
//    }
//    class func getTheUserId() -> String{
//        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        
//        var userName : String
////        userName = userDefaults.objectForKey(USERID) as! String
//        
//        return userName
//        
//    }
    
    
    class func uploadFileWithTheDetails(urlstr : String? , httpMethod : String? , httpReqbody : NSDictionary?, httpReqHeader : NSDictionary?, fileUrl : NSURL?, requestOrgnalData : Bool,onCompletionHandler : MyClosure ) {
        
        
        if (nil == urlstr  || nil == httpMethod || nil == fileUrl) {
            
            let errorDetails : NSError = NSError(domain: "", code: ERROR_CODE_PARA_MISSING, userInfo: nil)
            
            onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
            
        }
        
        let request = NSMutableURLRequest(URL:NSURL(string: urlstr!)!)
        
        request.HTTPMethod = httpMethod!
        
        //Body
        if( nil != httpReqbody) {
            
            do
            {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(httpReqbody!, options: NSJSONWritingOptions.PrettyPrinted)
            }
            catch
            {
                let errorDetails : NSError = NSError(domain: "", code: ERROR_CODE_PARA_MISSING, userInfo: nil)
                
                onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
            }
        }
        
        if( nil != httpReqHeader) {
            
            for (key, value) in httpReqHeader! {
                request.addValue(value as! String, forHTTPHeaderField: key as! String)
            }
        }
        
        //       request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.uploadTaskWithRequest(request, fromFile: fileUrl!, completionHandler: { data, response, error -> Void in
            
            
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if 500 == httpResponse.statusCode {
                    
                    let errorDetails : NSError? = NSError(domain: "", code: NSURLErrorTimedOut, userInfo: nil)
                    onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                    
                    
                }
                else {
                    
                    if( nil != error){
                        
                        
                        var errorDetails : NSError? = error
                        
                        if error?.code ==  NSURLErrorTimedOut {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_TIMED_OUT, userInfo: nil)
                            
                        }
                        else if NSURLErrorNotConnectedToInternet == error?.code {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_TIMED_OUT, userInfo: nil)
                            
                        }
                        else {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_UNABLE_TO_DOWNLOAD, userInfo: nil)
                            
                        }
                        
                        
                        onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                        
                    }
                        
                    else {
                        
                        
                        if true == requestOrgnalData{
                            
                            onCompletionHandler(data: data!, response: nil, msgError: nil)
                            
                        }
                        else {
                            
                            do {
                                
                                let parsedData: AnyObject?
                                
                                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                                
                                
                                onCompletionHandler(data: parsedData, response: nil, msgError: nil)
                            }
                            catch let error1 as NSError {
                                
                                var errorDetails : NSError? = error1
                                
                                errorDetails = NSError(domain: "", code: ERROR_CODE_UNABLE_TO_PARSE, userInfo: nil)
                                
                                onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                            }
                        }
                    }
                }
            }
            
        })
        
        task.resume()
        //return true
    }
    
    class func makeRequestWithTheDetails(urlstr : String? , httpMethod : String? , httpReqbody : NSDictionary?, httpReqHeader : NSDictionary?, requestOrgnalData : Bool,onCompletionHandler : MyClosure ) {
        
        if (nil == urlstr  || nil == httpMethod) {
            
            let errorDetails : NSError = NSError(domain: "", code: ERROR_CODE_PARA_MISSING, userInfo: nil)
            
            onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
        }
        
        let request = NSMutableURLRequest(URL:NSURL(string: urlstr!)!)
        request.HTTPMethod = httpMethod!
        
        //Body
        if( nil != httpReqbody) {
            
            do
            {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(httpReqbody!, options: NSJSONWritingOptions.PrettyPrinted)
            }
            catch
            {
                let errorDetails : NSError = NSError(domain: "", code: ERROR_CODE_PARA_MISSING, userInfo: nil)
                
                onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
            }
        }
        
        if( nil != httpReqHeader) {
            
            for (key, value) in httpReqHeader! {
                request.addValue(value as! String, forHTTPHeaderField: key as! String)
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if 500 == httpResponse.statusCode {
                    
                    let errorDetails : NSError? = NSError(domain: "", code: NSURLErrorTimedOut, userInfo: nil)
                    onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                    
                }
                else {
                    
                    if( nil != error){
                        
                        var errorDetails : NSError? = error
                        
                        if error?.code ==  NSURLErrorTimedOut {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_TIMED_OUT, userInfo: nil)
                        }
                        else if NSURLErrorNotConnectedToInternet == error?.code {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_TIMED_OUT, userInfo: nil)
                        }
                        else {
                            
                            errorDetails = NSError(domain: "", code: ERROR_CODE_UNABLE_TO_DOWNLOAD, userInfo: nil)
                        }
                        onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                    }
                        
                    else {
                        if true == requestOrgnalData{
                            
                            onCompletionHandler(data: data!, response: nil, msgError: nil)
                        }
                        else {
                            
                            do {
                                
                                let parsedData: AnyObject?
                                
                                parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                                
                                onCompletionHandler(data: parsedData, response: nil, msgError: nil)
                            }
                            catch let error1 as NSError {
                                
                                var errorDetails : NSError? = error1
                                
                                errorDetails = NSError(domain: "", code: ERROR_CODE_UNABLE_TO_PARSE, userInfo: nil)
                                
                                onCompletionHandler(data: nil, response: nil, msgError: errorDetails)
                            }
                        }
                    }
                }
            }
        })
        
        task.resume()
        //return true
    }
    
    
    class func createFilesDirectory() {
        
        var newDir : String = DataManager.getFilesDirectory()
        
        let fileManger = DataManager.sharedInstance.appFileManager
        
        do
        {
            try fileManger.createDirectoryAtPath(newDir, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            newDir = ""
        }
        
    }
    
    
    class func getFilesDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let newDir = String(format: "%@/%@", paths[0],USER_FILES_PATH)
        
        return newDir
    }
    
    
    class func getFilePath(fileId : String?, fileType : String?) -> String {
        
        var filePath = ""
        
        if nil != fileId && "" != fileId && nil != fileType && "" != fileType {
            
            filePath = String(format: "%@/%@.%@", getFilesDirectory(),fileId!,fileType! )
        }
        return filePath
    }
    
    
    class func saveTheFileById(pathForSaving:String, fileIdToDownload : String?, fileData : NSData?, Type : String?) -> Bool{
        
        var retVal = false
        
        
        if nil != fileIdToDownload && "" != fileIdToDownload && nil != fileData && nil != Type && "" != Type {
            
            let filename : String? = getFilePath(fileIdToDownload, fileType: Type)
            
            if nil != filename && "" != filename {
                
                retVal = fileData!.writeToFile(filename!, atomically: true)
                
            }
            
            
        }
        
        
        return retVal
    }
    
    
    
    class func getTheFileById(fileID : String?, fileType : String?) -> String{
        
        var filePath : String? = ""
        
        let fileManger = DataManager.sharedInstance.appFileManager
        
        
        if nil != fileID && "" != fileID {
            
            filePath = getFilePath(fileID, fileType: fileType)
            
            
            if nil != filePath && "" != filePath {
                
                if fileManger.fileExistsAtPath(filePath!) {
                    
                    
                }
                else {
                    
                    filePath = ""
                    
                }
                
            }
            
        }
        
        
        return filePath!
    }
    
    
    
    /*
     class func downloadTheFileById( downloadFinishedHandler : onDataDownLoadComplete , fileIdToDownload : String?, Type : String?){
     
     
     let projectUrlStr = "http://172.22.201.49:8085/api/SynnovationApi/getFileDownload/"
     
     
     let userInfo : Userdata = DataManager.getUserData()
     
     var urlStr : String?
     
     if nil != fileIdToDownload && "" != fileIdToDownload{
     
     urlStr = projectUrlStr.stringByAppendingString(fileIdToDownload!)
     
     DataManager.makeRequestWithTheDetails(urlStr, httpMethod: "GET", httpReqbody: nil, httpReqHeader: nil,requestOrgnalData: true, onCompletionHandler: {data, response, error -> Void in
     
     if( nil != error){
     
     downloadFinishedHandler(msgError: error)
     }
     else {
     
     let downloadedData = data as? NSData
     
     saveTheFileById("", fileIdToDownload: fileIdToDownload, fileData: downloadedData, Type: Type)
     
     downloadFinishedHandler(msgError: nil)
     
     }
     })
     }
     }
     
     class func downloadTheProjectsById( downloadFinishedHandler : onDataDownLoadComplete ){
     
     let projectUrlStr = "http://172.22.201.49:8085/api/SynnovationApi/getAllProjects"
     
     
     ///api/SynnovationApi/getFileDownload/FileId"
     
     let userInfo : Userdata = DataManager.getUserData()
     
     
     //        var urlStr : String?
     
     if(nil != userInfo.UserID) {
     
     // urlStr = projectUrlStr.stringByAppendingString(String(userInfo.UserID!))
     
     }
     
     DataManager.makeRequestWithTheDetails(projectUrlStr, httpMethod: "GET", httpReqbody: nil, httpReqHeader: nil,requestOrgnalData: false, onCompletionHandler: {data, response, error -> Void in
     
     
     if( nil != error){
     
     downloadFinishedHandler(msgError: error)
     }
     else {
     
     saveTheProjectDetails(data!)
     
     downloadFinishedHandler(msgError: nil)
     print("Body: \(data)")
     
     }
     })
     }
     
     func readTheUserdata(){
     
     let userNameObj :  String? = keychain.get(APP_USERNAME_KEY)
     
     if(nil != userNameObj) {
     userInfo.userName = userNameObj
     }
     
     
     let pwdNameObj :  String? = keychain.get(APP_PASSWORD_KEY)
     
     if(nil != pwdNameObj) {
     userInfo.passWord = pwdNameObj
     }
     
     
     let userIdObj :  String? = keychain.get(APP_USERID_KEY)
     
     if(nil != userIdObj) {
     userInfo.UserID = Int(userIdObj!)
     }
     
     }
     
     class func getUserData() -> Userdata{
     
     return DataManager.sharedInstance.userInfo
     
     }
     
     func saveUserData( userName : String, password : String, parsedData : AnyObject){
     
     let userInfoToBeStored = Userdata()
     
     userInfoToBeStored.userName = userName
     
     userInfoToBeStored.passWord = password
     
     
     if let items = parsedData as? NSDictionary {
     
     userInfoToBeStored.Email  = items["Email"] as? String
     
     userInfoToBeStored.SynechronUserID  = items["SynechronUserID"] as? String
     
     userInfoToBeStored.EmployeeName  = items["EmployeeName"] as? String
     
     userInfoToBeStored.FirstName  = items["FirstName"] as? String
     
     userInfoToBeStored.CreatedOn  = items["CreatedOn"] as? String
     
     userInfoToBeStored.CreatedBy  = items["CreatedBy"] as? String
     
     userInfoToBeStored.LastName  = items["LastName"] as? String
     
     userInfoToBeStored.UserID = items["UserID"] as? Int
     
     keychain.set(userInfoToBeStored.userName!, forKey: APP_USERNAME_KEY)
     keychain.set(userInfoToBeStored.passWord!, forKey: APP_PASSWORD_KEY)
     //      keychain.set(String(userInfoToBeStored.UserID!), forKey: APP_USERID_KEY)
     
     }
     
     DataManager.sharedInstance.userInfo = userInfoToBeStored
     }
     
     
     class func loginWithTheCredentials( userName : String, password : String, downloadFinishedHandler : onDataDownLoadComplete){
     
     let urlStr = "http://172.22.201.49:8085/api/SynnovationApi/ValidateUser"
     
     
     let para:NSMutableDictionary = NSMutableDictionary()
     para.setValue(userName, forKey: "UserName")
     para.setValue(password, forKey: "Password")
     
     
     DataManager.makeRequestWithTheDetails(urlStr, httpMethod: "POST", httpReqbody: para, httpReqHeader: nil, requestOrgnalData: false,onCompletionHandler: { data, response, error -> Void in
     
     
     if( nil != error){
     
     downloadFinishedHandler(msgError: error)
     }
     else {
     
     print("Body: \(data)")
     
     createFilesDirectory()
     
     
     DataManager.sharedInstance.saveUserData(userName, password: password, parsedData: data!)
     
     downloadFinishedHandler(msgError: nil)
     
     }
     }
     
     )
     
     
     
     /*
     
     let request = NSMutableURLRequest(URL: NSURL(string: "http://172.22.201.49:8085/api/SynnovationApi/getProjectDetails/1")!)
     
     request.HTTPMethod = "GET"
     
     let paramObj: AnyObject?
     
     //http://172.22.201.49:8085/api/SynnovationApi/getProjectDetails/1
     
     /*
     let para:NSMutableDictionary = NSMutableDictionary()
     para.setValue("kiran.muloor@synechron.com", forKey: "UserName")
     para.setValue("TestPassword", forKey: "Password")
     */
     var err: NSError?
     
     do
     {
     //  request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(para, options: NSJSONWritingOptions.PrettyPrinted)
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.addValue("application/json", forHTTPHeaderField: "Accept")
     }
     catch
     {
     print("Error:\n \(error)")
     return
     }
     
     
     let session = NSURLSession.sharedSession()
     
     let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
     
     var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
     print("Body: \(strData)")
     var err1: NSError?
     let json2 = 5//= NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
     print("json2 :\(json2)")
     
     if((err) != nil) {
     print(err!.localizedDescription)
     }
     else {
     //  var success = json2["success"] as? Int
     // print("Succes: \(success)")
     }
     
     })
     
     task.resume()
     
     */
     }
     
     /*
     class func parseJSONandSaveTheProjectData( projectData: AnyObject){
     
     
     let path = NSBundle.mainBundle().pathForResource("TempData", ofType: "json")//or rtf for an rtf file
     //        let text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
     
     var error: NSError?
     let anyObj: AnyObject?
     
     var stringData : String?
     
     do {
     stringData = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
     } catch let error1 as NSError {
     error = error1
     stringData = nil
     }
     
     
     let data = stringData!.dataUsingEncoding(NSUTF8StringEncoding)
     
     // convert NSData to 'AnyObject'
     
     
     do {
     anyObj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
     } catch let error1 as NSError {
     error = error1
     anyObj = nil
     }
     
     if let items = anyObj as? NSDictionary {
     
     let allProjects : NSArray = items["Data"] as! NSArray
     
     for eachProjectData  in allProjects {
     
     let eachProjectDict : NSDictionary = (eachProjectData as? NSDictionary)!
     
     let eachProject = EachProjectInfo()
     
     eachProject.Id = eachProjectDict["Id"] as? String
     
     eachProject.Title = eachProjectDict["Title"] as? String
     
     eachProject.Snippet = eachProjectDict["Snippet"] as? String
     
     eachProject.Account = eachProjectDict["Account"] as? String
     
     eachProject.Description = eachProjectDict["Description"] as? String
     
     eachProject.BusinessValue = eachProjectDict["BusinessValue"] as? Int
     
     eachProject.Category = eachProjectDict["Category"] as? String
     
     eachProject.ProjectContact = eachProjectDict["ProjectContact"] as? String
     
     eachProject.CreatedOn = eachProjectDict["CreatedOn"] as? String
     
     eachProject.UpdatedOn = eachProjectDict["UpdatedOn"] as? String
     
     
     //Just grab the project files
     
     let allAttachments : NSArray = eachProjectData["ProjectFiles"] as! NSArray
     
     let projectFiles = NSMutableArray()
     
     for eachAttachmentData  in allAttachments {
     
     let attachmentInfo = AttachmentInfo()
     
     attachmentInfo.ID = eachAttachmentData["ID"] as? Int
     
     attachmentInfo.FileName = eachAttachmentData["FileName"] as? String
     
     attachmentInfo.FileType = eachAttachmentData["FileType"] as? String
     
     attachmentInfo.Data = eachAttachmentData["Data"] as? String
     
     projectFiles.addObject(attachmentInfo)
     }
     
     eachProject.ProjectFiles = projectFiles
     
     
     //Just grab the project Benfits
     
     let allProjectBenfits : NSArray = eachProjectData["ProjectBenefits"] as! NSArray
     
     let projectBenfits = NSMutableArray()
     
     for eachProjectBenfitData  in allProjectBenfits {
     
     let projectBenfitInfo = EachBenfitInfo()
     
     projectBenfitInfo.ID = eachProjectBenfitData["ID"] as? Int
     
     projectBenfitInfo.Title = eachProjectBenfitData["Title"] as? String
     
     projectBenfitInfo.Description = eachProjectBenfitData["Description"] as? String
     
     projectBenfitInfo.CreatedOn = eachProjectBenfitData["CreatedOn"] as? String
     
     projectBenfitInfo.UpdatedOn = eachProjectBenfitData["UpdatedOn"] as? String
     
     projectBenfits.addObject(projectBenfitInfo)
     }
     
     eachProject.ProjectBenefits = projectBenfits
     
     
     //Just grab the project References
     
     let allProjectReferences : NSArray = eachProjectData["ProjectReference"] as! NSArray
     
     let projectReferences = NSMutableArray()
     
     for eachProjectReferenceData  in allProjectReferences {
     
     let projectReferenceInfo = EachProjectReference()
     
     projectReferenceInfo.ID = eachProjectReferenceData["ID"] as? String
     
     projectReferenceInfo.Title = eachProjectReferenceData["Title"] as? String
     
     projectReferenceInfo.Url = eachProjectReferenceData["Url"] as? String
     
     projectReferences.addObject(projectReferenceInfo)
     
     }
     
     eachProject.ProjectReference = projectReferences
     
     if(nil == DataManager.sharedInstance.projectList){
     
     DataManager.sharedInstance.projectList = NSMutableArray()
     
     }
     
     DataManager.sharedInstance.projectList?.addObject(eachProject)
     }
     }
     }
     
     */
     
     class func getEachProjectReference( eachProjectReferenceData : AnyObject) -> EachProjectReference {
     
     let projectReferenceInfo = EachProjectReference()
     
     projectReferenceInfo.CreatedBy = eachProjectReferenceData["CreatedBy"] as? Int
     
     projectReferenceInfo.CreatedDate = eachProjectReferenceData["CreatedDate"] as? String
     
     projectReferenceInfo.ID = eachProjectReferenceData["ID"] as? Int
     
     projectReferenceInfo.ProjectID = eachProjectReferenceData["ProjectID"] as? Int
     
     projectReferenceInfo.Projects = eachProjectReferenceData["Projects"] as? String
     
     projectReferenceInfo.Title = eachProjectReferenceData["Title"] as? String
     
     projectReferenceInfo.URL = eachProjectReferenceData["URL"] as? String
     
     projectReferenceInfo.Description = eachProjectReferenceData["Description"] as? String
     
     
     
     return projectReferenceInfo
     
     }
     
     
     class func getEachProjectBenfit( eachProjectBenfitData : AnyObject) -> EachBenfitInfo {
     
     let projectBenfitInfo = EachBenfitInfo()
     
     projectBenfitInfo.ID = eachProjectBenfitData["ID"] as? Int
     
     projectBenfitInfo.BenefitID = eachProjectBenfitData["BenefitID"] as? Int
     
     projectBenfitInfo.BenefitName = eachProjectBenfitData["BenefitName"] as? String
     
     projectBenfitInfo.CreatedBy = eachProjectBenfitData["CreatedBy"] as? Int
     
     projectBenfitInfo.CreatedDate = eachProjectBenfitData["CreatedDate"] as? String
     
     projectBenfitInfo.ProjectID = eachProjectBenfitData["ProjectID"] as? Int
     
     projectBenfitInfo.Projects = eachProjectBenfitData["ProjectID"] as? String
     
     return projectBenfitInfo
     }
     
     
     class func getEachProjectFile( eachAttachmentData : AnyObject) -> AttachmentInfo {
     
     let attachmentInfo = AttachmentInfo()
     
     attachmentInfo.CreatedBy = eachAttachmentData["CreatedBy"] as? Int
     
     attachmentInfo.CreatedDate = eachAttachmentData["CreatedDate"] as? String
     
     attachmentInfo.FileData = eachAttachmentData["FileData"] as? String
     
     attachmentInfo.FileName = eachAttachmentData["FileName"] as? String
     
     attachmentInfo.ID = eachAttachmentData["ID"] as? Int
     
     attachmentInfo.MimeType = eachAttachmentData["MimeType"] as? String
     
     attachmentInfo.ProjectID = eachAttachmentData["ProjectID"] as? Int
     
     attachmentInfo.Projects = eachAttachmentData["ProjectID"] as? String
     
     attachmentInfo.FileSize = eachAttachmentData["FileSize"] as? String
     
     
     
     return attachmentInfo
     }
     
     
     
     class func getEachProject( eachProjectData : AnyObject) -> EachProjectInfo {
     
     
     let eachProjectDict : NSDictionary = (eachProjectData as? NSDictionary)!
     
     let eachProject = EachProjectInfo()
     
     eachProject.Id = eachProjectDict["Id"] as? String
     
     eachProject.Title = eachProjectDict["Title"] as? String
     
     eachProject.Snippet = eachProjectDict["Snippet"] as? String
     
     eachProject.Account = eachProjectDict["Account"] as? String
     
     eachProject.Description = eachProjectDict["Description"] as? String
     
     eachProject.BusinessValue = eachProjectDict["BusinessValue"] as? Int
     
     eachProject.Category = eachProjectDict["Category"] as? String
     
     
     eachProject.CategoryID = eachProjectDict["CategoryID"] as? Int
     
     eachProject.ProjectContact = eachProjectDict["ProjectContact"] as? String
     
     eachProject.CreatedOn = eachProjectDict["CreatedOn"] as? String
     eachProject.CreatedByName = eachProjectDict["CreatedByName"] as? String
     
     eachProject.CreatedDate = eachProjectDict["CreatedDate"] as? String
     
     
     eachProject.UpdatedOn = eachProjectDict["UpdatedOn"] as? String
     
     
     //Just grab the project files
     
     if let allAttachments = eachProjectDict["ProjectFileUpload"] as? NSArray{
     
     let projectFiles = NSMutableArray()
     
     
     for eachAttachmentData  in allAttachments {
     
     let attachmentInfo = getEachProjectFile(eachAttachmentData)
     
     projectFiles.addObject(attachmentInfo)
     }
     
     eachProject.ProjectFiles = projectFiles
     
     }
     else {
     
     let attachmentInfo = getEachProjectFile(eachProjectDict["ProjectFileUpload"]!)
     
     let projectFiles = NSMutableArray()
     
     projectFiles.addObject(attachmentInfo)
     
     eachProject.ProjectFiles = projectFiles
     }
     
     
     
     //Benfits
     
     if let allProjectBenfits = eachProjectDict["ProjectBenefits"] as? NSArray{
     
     let projectBenfits = NSMutableArray()
     
     
     for eachProjectBenfitData  in allProjectBenfits {
     
     let projectBenfitInfo = getEachProjectBenfit(eachProjectBenfitData)
     
     projectBenfits.addObject(projectBenfitInfo)
     }
     
     eachProject.ProjectBenefits = projectBenfits
     
     }
     else {
     
     let projectBenfits = NSMutableArray()
     
     let projectBenfitInfo = getEachProjectBenfit(eachProjectDict["ProjectBenefits"]!)
     
     projectBenfits.addObject(projectBenfitInfo)
     
     eachProject.ProjectBenefits = projectBenfits
     }
     
     
     
     //Just grab the project References
     
     if let allProjectReferences = eachProjectDict["ProjectsReferences"] as? NSArray{
     
     let projectReferences = NSMutableArray()
     
     for eachProjectReferenceData  in allProjectReferences {
     
     let projectReferenceInfo = getEachProjectReference(eachProjectReferenceData)
     
     projectReferences.addObject(projectReferenceInfo)
     }
     
     eachProject.ProjectReference = projectReferences
     
     }
     else {
     
     let projectReferences = NSMutableArray()
     
     let projectReferenceInfo = getEachProjectReference(eachProjectDict["ProjectsReferences"]!)
     
     projectReferences.addObject(projectReferenceInfo)
     
     eachProject.ProjectReference = projectReferences
     }
     
     
     
     
     if(nil == DataManager.sharedInstance.projectList){
     
     DataManager.sharedInstance.projectList = NSMutableArray()
     
     }
     
     
     return eachProject
     
     }
     
     
     
     
     
     class func saveTheProjectDetails( projectData: AnyObject){
     
     
     print(projectData)
     
     
     if let allProjects = projectData as? NSArray {
     
     
     for eachProjectData  in allProjects {
     
     
     let eachProject = getEachProject(eachProjectData)
     
     DataManager.sharedInstance.projectList?.addObject(eachProject)
     }
     }
     
     else {
     
     let eachProject = getEachProject(projectData)
     
     DataManager.sharedInstance.projectList?.addObject(eachProject)
     
     
     }
     }
     
     
     
     class func resetTheFilterData (){
     
     DataManager.sharedInstance.populateInitialFilterData()
     
     }
     
     class func resetTheProjectDataData (){
     
     DataManager.sharedInstance.projectList = NSMutableArray()
     
     }
     
     class func prepareDataForCategoryTable () -> NSMutableArray {
     
     let retValue : NSMutableArray = NSMutableArray()
     
     retValue.addObject(["Services",false,"1"])
     retValue.addObject(["Platform",false,"2"])
     retValue.addObject(["Practice",false,"3"])
     retValue.addObject(["Talent",false,"4"])
     
     
     return retValue
     }
     
     class func getTheInitialDataForFilter()->FilterDetails {
     
     
     let filterObjDetails = FilterDetails()
     
     filterObjDetails.filterCategories = DataManager.prepareDataForCategoryTable()
     
     return filterObjDetails
     
     }
     
     
     func populateInitialFilterData(){
     
     filterDetails = DataManager.getTheInitialDataForFilter()
     
     }
     
     class func saveTheFilterDetails( filterResultsToSave: FilterDetails){
     
     DataManager.sharedInstance.filterDetails = filterResultsToSave
     
     }
     
     
     class func getTheFilterDetails() -> FilterDetails{
     
     return DataManager.sharedInstance.filterDetails!
     }
     
     }
     
     extension String{
     func getPathExtension() -> String{
     return (self as NSString).pathExtension
     }
     
     */
}


