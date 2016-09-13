//
//  ViewController.swift
//  Sniper
//
//  Created by Paulo Lam on 08/23/2016.
//  Copyright (c) 2016 Paulo Lam. All rights reserved.
//

import UIKit
import Sniper

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(wordDictDidSync(_:)), name: SniperWordDictDidSyncNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(localeIdentifierDidUpdate(_:)), name: SniperLocaleIdentifierDidUpdateNotification, object: nil)
    Sniper.sharedInstance.addSupportingLanguage("en", languageDescription: "English", languageFileName: "en")
    Sniper.sharedInstance.addSupportingLanguage("zh-Hant", languageDescription: "繁體中文", languageFileName: "zh-Hant")
    Sniper.sharedInstance.addSupportingLanguage("ja", languageDescription: "日文", languageFileName: "ja")
    Sniper.saveSelectedLocaleIdentifier("en")
    Sniper.sharedInstance.retrieveRemoteWordDict("1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ")
  }
  
  func wordDictDidSync(notify:NSNotification) {
    for locale in Sniper.sharedInstance.getAvailableLocaleList() {
      Sniper.saveSelectedLocaleIdentifier(locale)
    }
  }
  
  func localeIdentifierDidUpdate(notify:NSNotification) {
      print("------\(Sniper.sharedInstance.getCurrentLocaleIdentifier())------")
      print("TXT_test".localizedString())
      print("TXT_test2".localizedString())
      print("TXT_test3".localizedString())
      print("TXT_test4".localizedString())
      print("TXT_test5".localizedString())
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

