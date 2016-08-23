import Foundation
import Alamofire
import CSwiftV

public let kWordDictDidSyncNotification = "kWordDictDidSyncNotification"
typealias StringsDict = [String:String]

@objc public class Sniper : NSObject {
  public static let sharedInstance = Sniper(locales: "en")
  
  let levels = ["base", "sync", "project"]
  
  var languageLocaleList: [String]
  var languageDict: [String:StringsDict] = [String:StringsDict]()
  var bundle: NSBundle
  var googleSpreadSheetKey : String?
  var hasRemoteSpreadSheetKey : Bool {
    get {
      if let googleSpreadSheetKey = googleSpreadSheetKey {
        return true
      }
      return false
    }
  }
  var remoteLanguageOptions: [String]?
  
  public var locale: String
  
  convenience public init(locales : String...) {
    self.init(bundle: NSBundle.mainBundle(), locale: NSLocale.currentLocale(), locales: locales)
  }
  
  convenience public init(bundle: NSBundle, locales : String...) {
    self.init(bundle: bundle, locale: NSLocale.currentLocale(), locales: locales)
  }
  
  convenience public init(locale: NSLocale, locales : [String]) {
    self.init(bundle: NSBundle.mainBundle(), locale: locale, locales: locales)
  }
  
  convenience public init(bundle: NSBundle, locale: NSLocale, locales : String...) {
    self.init(bundle: bundle, locale: locale, locales: locales)
  }
  
  public init(bundle: NSBundle, locale: NSLocale, locales : [String]) {
    self.bundle = bundle
    self.languageLocaleList = locales
    self.locale = self.languageLocaleList[0]
    self.googleSpreadSheetKey = nil
    
    let language = locale.localeIdentifier
    //print(language)
    if languageLocaleList.contains(language) {
      self.locale = language
    }
    super.init()
    buildLanguageData()
    getRemoteWordDict(self.googleSpreadSheetKey)
  }
  
  public func getString(key: String) -> String {
    let wordings = languageDict[self.locale]
    if let w = wordings {
      if w.keys.contains(key).boolValue {
        return w[key]!
      }
    }
    //    NSException(name: "KeyNotFoundException",
    //                reason: "Key - \(key) not found in language [zh-Hant]",
    //                userInfo: nil).raise()
    return ""
  }
  
  func buildLanguageData(){
    languageDict.removeAll()
    
    for locale in languageLocaleList {
      var stringsDict : StringsDict = StringsDict()
      languageDict[locale] = stringsDict
      
      for level in levels {
        let fileName = locale + "." + level
        let filePath = self.bundle.pathForResource(fileName, ofType: "strings")
        if filePath == nil {
          printLog(fileName + " is not available")
          continue
        }
        
        let rawStringDict = NSDictionary(contentsOfFile: filePath!)
        if let dict = rawStringDict {
          for (rawStringKey, rawStringValue) in dict {
            stringsDict[rawStringKey as! String] = rawStringValue as? String
          }
        } else {
          printLog(fileName + " is not available")
          continue
        }
      }
      languageDict[locale] = stringsDict
    }
  }
  
  public func getAvailableLocaleList() -> [String] {
    return languageLocaleList
  }
  
  public func getAvailableLanguageOptions() -> [String] {
    return remoteLanguageOptions ?? []
  }
  
  func printLog(log : String){
    print("[RSMultiLanguage] " + log)
  }
  
}

// MARK: Google Spread Sheet
extension Sniper {
  public func setAvailableLanguage(locale:NSLocale? ,locales:String...) {
    self.languageLocaleList = locales
    self.locale = self.languageLocaleList[0]
    
    if let locale = locale {
      let language = locale.localeIdentifier
      //print(language)
      if languageLocaleList.contains(language) {
        self.locale = language
      }
    }
    else {
      let locale = NSLocale.currentLocale()
      let language = locale.localeIdentifier
      //print(language)
      if languageLocaleList.contains(language) {
        self.locale = language
      }
    }
    
    buildLanguageData()
  }
  
  public func getRemoteWordDict(key : String?) {
    if let key = key {
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
                  let a = Float(version)
                  let b = Float(minVersion)
                  
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
          
          let csv = CSwiftV(string: content)
          
          var wordDict = [String:StringsDict]()
          var locales = csv.headers
          locales.removeFirst()
          self.languageLocaleList = locales
          if !self.languageLocaleList.contains(self.locale) {
            self.locale = self.languageLocaleList[0]
          }
          for lang in self.languageLocaleList {
            wordDict[lang] = [:]
          }
          
          let rows = csv.rows
          for index in 0..<rows.count {
            let row = rows[index]
            let columns = row
            
            if index == 0 {
              var options = columns
              options.removeFirst()
              self.remoteLanguageOptions = options
            }
            else {
              if columns.count >= self.languageLocaleList.count {
                let wordKey = columns[0]
                for wordIndex in 1..<columns.count {
                  let word = columns[wordIndex]
                  if wordIndex-1 < self.languageLocaleList.count {
                    let locale = self.languageLocaleList[wordIndex-1]
                    if var langWords = wordDict[locale] {
                      langWords[wordKey] = word
                      wordDict[locale] = langWords
                    }
                  }
                }
              }
            }
          }
          //          print("-----localelist-----\n\(self.languageLocaleList)\n")
          //          print("-----options-----\n\(self.remoteLanguageOptions!)\n")
          //          print("-----worddict-----\n\(wordDict)\n")
          self.languageDict = wordDict
          
          NSNotificationCenter.defaultCenter().postNotificationName(kWordDictDidSyncNotification, object: nil)
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