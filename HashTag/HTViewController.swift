//
//  ViewController.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//
import Accounts
import UIKit

class HTViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let kcellIdentifier = "reuseIdentifier"
    
    var twitterManager: TwitterManager? = nil
    var json: NSMutableArray = []
    var searchTag: String = " "
    var maxId: String? = nil
    
    @IBOutlet var activity: UIActivityIndicatorView
    
    @IBOutlet
    var tableView: UITableView
    
    @IBOutlet
    var textField: UITextField
    
    let failureHandler: ((NSError) -> Void) = {
        error in
        
        println(error.localizedDescription)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(RJTableViewCell.self, forCellReuseIdentifier: kcellIdentifier)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "contentSizeCategoryChanged:",
                                                         name: UIContentSizeCategoryDidChangeNotification,
                                                         object: nil)
    }
    
    // This method is called when the Dynamic Type user setting changes
    func contentSizeCategoryChanged(notification: NSNotification) {
        self.tableView.reloadData()
    }
    
    @IBAction func HashTagTapped(sender: AnyObject) {
        
        let accountStore = ACAccountStore()
        self.maxId = nil
        self.json = []
        self.searchTag = self.textField.text
        
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType) {
            granted, error in
            var twitterManager: TwitterManager
            if granted {
                let twitterAccounts = accountStore.accountsWithAccountType(accountType)

                let twitterAccount = twitterAccounts[0] as ACAccount
                self.twitterManager = TwitterManager(account: twitterAccount)
                
                self.showTweets(self.twitterManager)
                
            } else {
                self.twitterManager =
                    TwitterManager(consumerKey:    "liIvW0GeBKbljCRuFZLLN9kVI",
                        consumerSecret: "I230kVapeP0qVnbuKU1990cGlL46VUvzFmu112EfIXOQKxVq4U")
                
                self.twitterManager!.authorizeWithCallbackURL(NSURL(string: "hashtag://success"),
                    success: {
                        accessToken, response in
                        
                        self.showTweets(self.twitterManager)
                        
                    }, failure: self.failureHandler)
            }
        }
    }
    
    func showTweets(tm: TwitterManager!) {
        dispatch_async(dispatch_get_main_queue()) {
            let end = self.textField.endEditing(true)
        }
        
        if self.searchTag.length() <= 1 { return }
        
        self.activity.startAnimating()
        tm.getSearchTweetsWithQuery("\(self.searchTag)",
            geocode: nil,
            lang: nil,
            locale: nil,
            resultType: nil,
            count: nil,
            until: nil,
            sinceID: nil,
            maxID: self.maxId,
            includeEntities: nil,
            callback: nil,
            success: { jsonRaw, response in
                if let json = jsonRaw as? NSDictionary {
                    println(json)
                    if let aJson = json["statuses"] as? NSArray {
                        
                        if aJson.count == 0 {
                            self.json = []
                            self.tableView.reloadData() 
                            self.activity.stopAnimating()
                            return
                        }
                        self.json.addObjectsFromArray(aJson)
                        
                        if let nextId = jsonRaw["search_metadata"] as? NSDictionary {
                            println(nextId)
                            if let nextMaxId = nextId["next_results"] as? String {
                                let parameters = nextMaxId.parametersFromQueryString()
                                println(parameters)
                                self.maxId = parameters["?max_id"]
                                println(self.maxId)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                self.activity.stopAnimating()
                
                
            },
            failure: self.failureHandler)
        
    }
    
        func populateCell(aCell: RJTableViewCell, path: NSIndexPath) {
            aCell.updateFonts()
            let obj = self.json[path.row] as NSDictionary
            let user = obj["user"] as NSDictionary
    
            aCell.titleLabel.text = user["screen_name"] as NSString
            aCell.bodyLabel.text = obj["text"] as String
    
            aCell.needsUpdateConstraints()
            aCell.updateConstraintsIfNeeded()
        }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.json.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let cell: RJTableViewCell = tableView.dequeueReusableCellWithIdentifier(kcellIdentifier, forIndexPath: indexPath) as RJTableViewCell
        
        self.populateCell(cell , path: indexPath)
        
        let obj =  json[indexPath.row] as NSDictionary
        let rtCount : NSNumber = obj["retweet_count"] as NSNumber
        
        if rtCount.integerValue == 0 {
            cell.backgroundColor = UIColor.whiteColor()
        } else {
            cell.backgroundColor = UIColor.grayColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell: RJTableViewCell = RJTableViewCell()
        
        self.populateCell(cell, path: indexPath)
        
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds))
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var height: CGFloat = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        height += 1
        return height
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView!) {
        let height: CGFloat = scrollView.frame.size.height
        
        let contentYOffset: CGFloat = scrollView.contentOffset.y
        
        let distanceFromBottom: CGFloat = scrollView.contentSize.height - contentYOffset
        if(distanceFromBottom < height)
        {
            showTweets(self.twitterManager)
        }
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange aRange: NSRange, replacementString string: String!) -> Bool {
        
        if aRange.location == 0 {
            return false
        } else {
            return true
        }
    }
}