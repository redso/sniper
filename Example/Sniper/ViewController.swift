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
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(wordDictDidSync(_:)), name: kWordDictDidSyncNotification, object: nil)
    Sniper.sharedInstance.setAvailableLanguage(nil, locales: "en", "zh")
    print("TXT_test".localizedString())
    print("TXT_test2".localizedString())
    print("TXT_test3".localizedString())
    print("TXT_test4".localizedString())
    print("TXT_test5".localizedString())
    //Test.tryPrint()
    Sniper.sharedInstance.getRemoteWordDict("1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ")
    
    
  }
  
  func wordDictDidSync(notify:NSNotification) {
    for locale in Sniper.sharedInstance.getAvailableLocaleList() {
      Sniper.sharedInstance.locale = locale
      print("TXT_test".localizedString())
      print("TXT_test2".localizedString())
      print("TXT_test3".localizedString())
      print("TXT_test4".localizedString())
      print("TXT_test5".localizedString())
      //Test.tryPrint()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}

