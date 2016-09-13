import Foundation
import Alamofire
import CSwiftV

public let SniperWordDictDidSyncNotification = "SniperWordDictDidSyncNotification"
public let SniperLocaleIdentifierDidUpdateNotification = "SniperLocaleIdentifierDidSavedNotification"

typealias StringsDict = [String:String]

struct Language {
  var localeIdentifier : String
  var wordDict : StringsDict = StringsDict()
  var languageDescription : String
}


@objc public class Sniper : NSObject {
  public static let sharedInstance = Sniper(bundle: NSBundle.mainBundle(), locale: NSLocale.currentLocale())
  
  var localeIdentifier: String {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(SniperLocaleIdentifierDidUpdateNotification, object: nil)
    }
  }
  var languages : [String:Language] = [String:Language]()
  var bundle: NSBundle
  var googleSpreadSheetKey : String?
  
  public class func selectedLocaleIdentifier() -> String? {
    return NSUserDefaults.standardUserDefaults().objectForKey("sniper.selectedLocaleIdentifier.value") as? String
  }
  
  public class func saveSelectedLocaleIdentifier(localeIdentifier:String) {
    Sniper.sharedInstance.localeIdentifier = localeIdentifier
    return NSUserDefaults.standardUserDefaults().setObject(localeIdentifier, forKey: "sniper.selectedLocaleIdentifier.value")
  }
  
  public init(bundle: NSBundle, locale : NSLocale) {
    self.bundle = bundle
    
    if let storedIdentifier = Sniper.selectedLocaleIdentifier() {
      self.localeIdentifier = storedIdentifier
    }
    else {
      self.localeIdentifier = locale.localeIdentifier
    }
    
    super.init()
    if let content = self.loadCachedContent() {
      self.parseSpreadSheetContent(content)
    }
  }
  
  public func getString(key: String) -> String {
    if let language = languages[self.localeIdentifier] {
      if language.wordDict.keys.contains(key).boolValue {
        return language.wordDict[key]!
      }
    }
    //    NSException(name: "KeyNotFoundException",
    //                reason: "Key - \(key) not found in language [zh-Hant]",
    //                userInfo: nil).raise()
    return ""
  }
    
  public func addSupportingLanguage(localeIdentifier:String, languageDescription:String, languageFileName:String) {
    
    let filePath = self.bundle.pathForResource(languageFileName, ofType: "strings")
    if filePath == nil {
      printLog(languageFileName + " is not available")
      return
    }
    
    var stringsDict : StringsDict = StringsDict()
    let rawStringDict = NSDictionary(contentsOfFile: filePath!)
    if let dict = rawStringDict {
      for (rawStringKey, rawStringValue) in dict {
        stringsDict[rawStringKey as! String] = rawStringValue as? String
      }
    } else {
      printLog(languageFileName + " is not available")
      return
    }
    
    let newLanguage = Language(localeIdentifier: localeIdentifier, wordDict: stringsDict, languageDescription: languageDescription)
    self.languages[localeIdentifier] = newLanguage
  }
  
  func addSupportingLanguage(localeIdentifier:String, languageDescription:String, wordDict:StringsDict) {
    let newLanguage = Language(localeIdentifier: localeIdentifier, wordDict: wordDict, languageDescription: languageDescription)
    self.languages[localeIdentifier] = newLanguage
  }
  
  
  public func getCurrentLocaleIdentifier() -> String {
    return self.localeIdentifier
  }
  
  public func getAvailableLocaleList() -> [String] {
    var list = [String]()
    for (_, value) in languages {
      list.append(value.localeIdentifier)
    }
    return list
  }
  
  public func getAvailableLanguageOptions() -> [String] {
    var list = [String]()
    for (_, value) in languages {
      list.append(value.languageDescription)
    }
    return list
  }
  
  func printLog(log : String){
    print("[Sniper] " + log)
  }
  
}

// MARK: Google Spread Sheet
extension Sniper {
  
  public func retrieveRemoteWordDict(googleSpreadSheetKey : String?) {
    if let key = googleSpreadSheetKey {
      self.googleSpreadSheetKey = key
      //"https://docs.google.com/spreadsheets/u/1/d/1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ/export?exportFormat=csv&gid=1133219217"
      Alamofire.request(.GET, "https://docs.google.com/spreadsheets/u/1/d/\(key)/export?exportFormat=csv").responseData(completionHandler: { (response) in
        if response.result.isSuccess {
          if var content = String.init(data: response.data!, encoding:NSUTF8StringEncoding) {
            //print (content)
            let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
            let version = nsObject as! String
            var gid : String?
            
            content = content.stringByReplacingOccurrencesOfString("\r", withString: "")
            let rows = content.componentsSeparatedByString("\n")
            for row in rows {
              let columns = row.componentsSeparatedByString(",")
              if columns.count >= 2 {
                let platform = columns[0]
                let minVersion = columns[1]
                let tmpGid = columns[2]
                
                if platform == "ios" {
                  if Float(version) >= Float(minVersion) {
                    gid = tmpGid
                  }
                }
              }
            }
            
            if let gid = gid {
              self.getSpecificVersionOfWordDict(key, gid: gid)
            }
          }
          else {
            print("FAILURE")
            print(response.request)
            print(response.response)
          }
        }
        else {
          print("FAILURE")
          print(response.request)
          print(response.response)
        }
      })
    }
  }
  
  func getSpecificVersionOfWordDict(key:String, gid:String) {
    //"https://docs.google.com/spreadsheets/u/1/d/1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ/export?exportFormat=csv&gid=1133219217"
    Alamofire.request(.GET, "https://docs.google.com/spreadsheets/u/1/d/\(key)/export?exportFormat=csv&gid=\(gid)").responseData(completionHandler: { (response) in
      if response.result.isSuccess {
        if let content = String.init(data: response.data!, encoding:NSUTF8StringEncoding) {
          //print (content)
          self.languages.removeAll()
          
          self.parseSpreadSheetContent(content)
          self.persistentContent(content)
          
          NSNotificationCenter.defaultCenter().postNotificationName(SniperWordDictDidSyncNotification, object: nil)
        }
        else {
          print("FAILURE")
          print(response.request)
          print(response.response)
        }
      }
      else {
        print("FAILURE")
        print(response.request)
        print(response.response)
      }
    })
  }
  
  func parseSpreadSheetContent(content:String) {
    let csv = CSwiftV(string: content)
    
    var wordDicts = [String:StringsDict]()
    var locales = csv.headers
    locales.removeFirst()
    var localeDesc = [String]()
    
    if !locales.contains(self.localeIdentifier) {
      self.localeIdentifier = locales[0]
    }
    
    for lang in locales {
      wordDicts[lang] = [:]
    }
    
    let rows = csv.rows
    for index in 0..<rows.count {
      let row = rows[index]
      let columns = row
      
      if index == 0 {
        var options = columns
        options.removeFirst()
        localeDesc = options
      }
      else {
        if columns.count >= locales.count {
          let wordKey = columns[0]
          for wordIndex in 1..<columns.count {
            let word = columns[wordIndex]
            if wordIndex-1 < locales.count {
              let locale = locales[wordIndex-1]
              if var langWords = wordDicts[locale] {
                langWords[wordKey] = word
                wordDicts[locale] = langWords
              }
            }
          }
        }
      }
      
      for index in 0..<locales.count {
        self.addSupportingLanguage(locales[index], languageDescription: localeDesc[index], wordDict: wordDicts[locales[index]]!)
      }
    }
    //          print("-----localelist-----\n\(self.languageLocaleList)\n")
    //          print("-----options-----\n\(self.remoteLanguageOptions!)\n")
    //          print("-----worddict-----\n\(wordDict)\n")
  }
  
  
  func resourcesDirectory() -> String? {
    let directory = NSSearchPathDirectory.DocumentDirectory
    let domainMask = NSSearchPathDomainMask.UserDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
    
    if paths.count > 0 {
      if let dirPath = paths.first {
        return dirPath
      }
    }
    else {
      printLog("resourcesStorePath fail, no resourcesStorePath")
    }
    
    return nil
  }
  
  func persistentContent(content:String) {
    if let dirPath = self.resourcesDirectory() {
      let filePath = dirPath+"/sniper_cache.txt"
      if let data = content.dataUsingEncoding(NSUTF8StringEncoding) {
        data.writeToFile(filePath, atomically: true)
      }
    }
  }
  
  func loadCachedContent() -> String? {
    if let dirPath = self.resourcesDirectory() {
      let readPath = dirPath+"/sniper_cache.txt"
      
      do {
        let content = try NSString(contentsOfFile: readPath, encoding: NSUTF8StringEncoding)
        return content as String
      } catch let error as NSError {
        print(error.localizedDescription)
        return nil
      }
    }
    
    return nil
  }
}