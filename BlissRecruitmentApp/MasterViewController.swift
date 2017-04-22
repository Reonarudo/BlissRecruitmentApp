//
//  MasterViewController.swift
//  BlissRecruitmentApp
//
//  Created by Leonardo Marques on 20.04.17.
//  Copyright © 2017 Leonardo Marques. All rights reserved.
//

import UIKit
import KRProgressHUD

class MasterViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    // MARK: - Properties
    let searchController = UISearchController(searchResultsController: nil)
    
    var detailViewController: DetailViewController? = nil
    var questions: Array<Question> = Array<Question>()
    var filteredQuestions: Array<Question> = Array<Question>()
    
    //Qestion data opened from link
    var linkQuestion:Question?
    
    //Question list paging
    let kQuestionsPerPage:Int=10
    
    //Starts at one because the controller fetches the first batch on load
    var page:Int=1
    var filterPage:Int=1
    
    
    override func viewDidLoad() {
        //Go to loading screen before loading the master view
        showLoadingView()
        
        //Subscribe for external question notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveQuestionNotification(notification:)), name: NSNotification.Name("BRAQuestionNotification"), object: nil)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //navigationItem.leftBarButtonItem = editButtonItem
        
        //Setup search
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        //searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView=searchController.searchBar
        
        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.tableView.contentOffset = CGPoint(x: 0, y: self.searchController.searchBar.frame.size.height)
        //Fetch initial content
        BRAPI.sharedInstance.getAllQuestions(kQuestionsPerPage, 0, success: { (response) in
            self.questions=(response["questions"] as! Array<[String:Any?]>).flatMap{
                Question.getQuestion(from: $0)
            }
        }) { (error) in
            print("Failed to fetch question batch")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        if (navigationController?.navigationBar.isHidden)! {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
        
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
     func insertNewObject(_ sender: Any) {
     questions.insert(NSDate(), at: 0)
     let indexPath = IndexPath(row: 0, section: 0)
     tableView.insertRows(at: [indexPath], with: .automatic)
     }
     */
    // MARK: - Notifications handler
    
    func didRecieveQuestionNotification(notification: Notification){
        //Handle question query
        let userInfo = notification.userInfo as! [String: AnyObject]
        //Clean up url to extract query
        
        guard let queryComponents:[String]=(userInfo["query"] as? String)?.capturedGroups(
            withRegex: "blissrecruitment://questions\\?(\\w+)?=(.*)?") else{
                print("Invalid query")
                return
        }
        
        
        if queryComponents[0].hasPrefix("question_filter"){
            self.filterSearch(with: queryComponents[1] ?? "")
        }
        if queryComponents[0].hasPrefix("question_id"){
            self.showQuestion(with: Int(queryComponents[1])!)
        }
        
    }
    
    //Filter search
    func filterSearch(with parameters:String) {
        self.tableView.contentOffset = CGPoint(x: 0, y: -2*searchController.searchBar.frame.size.height)
        searchController.searchBar.text=parameters
        self.updateSearchResults(for: self.searchController)
    }
    
    //Show question
    func showQuestion(with number:Int) {
        BRAPI.sharedInstance.getQuestion(number, success: { (result) in
            self.linkQuestion=Question.getQuestion(from: result)
            self.performSegue(withIdentifier: "showDetail", sender: nil)
        }) { (error) in
            print("Failed to load question")
        }
    }
    
    //Should not be needed since the class should not be deallocated during the app lifetime
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            //Either called from link of from list
            if let question = linkQuestion{
                let object = question
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailQuestion = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                //reset so it doesn't open the same question everytime the segue is called
                linkQuestion=nil
                
            }else if let indexPath = tableView.indexPathForSelectedRow {
                //Take into account filtered results
                let object = !searchController.isActive ? questions[indexPath.row] : filteredQuestions[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailQuestion = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                //hide searchbar
                searchController.dismiss(animated: false, completion: nil)
            }
            
        }
    }
    
    func showLoadingView(){
        self.performSegue(withIdentifier: "segueLoadingScreen", sender: nil)
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive{
            return filteredQuestions.count
        }else{
            return questions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if searchController.isActive{
            //Setup cell apperance
            cell.textLabel!.text = filteredQuestions[indexPath.row].question
            cell.imageView?.imageFromServerURL(urlString: filteredQuestions[indexPath.row].thumbURL)
        }else{
            //Setup cell apperance
            cell.textLabel!.text = questions[indexPath.row].question
            cell.imageView?.imageFromServerURL(urlString: questions[indexPath.row].thumbURL)
        }
        
        
        //Fetch new page of questions before showing the last cell
        
        //Take into account paging for the filtered results
        if searchController.isActive{
            if(indexPath.row == (filterPage*kQuestionsPerPage-1)){
                let searchText:String=searchController.searchBar.text!
                BRAPI.sharedInstance.getAllQuestions(kQuestionsPerPage, filterPage*kQuestionsPerPage, searchText, success: { (response) in
                    //append fetched questions
                    self.filteredQuestions.append(contentsOf: (response["questions"] as! Array<[String:Any?]>).flatMap{
                        Question.getQuestion(from: $0)
                    })
                    //next page
                    self.filterPage+=1
                    self.tableView.reloadData()
                }) { (error) in
                    print("Failed to fetch question batch")
                }
            }
        }else{
            if(indexPath.row == (page*kQuestionsPerPage-1)){
                BRAPI.sharedInstance.getAllQuestions(kQuestionsPerPage, page*kQuestionsPerPage, success: { (response) in
                    //append fetched questions
                    self.questions.append(contentsOf: (response["questions"] as! Array<[String:Any?]>).flatMap{
                        Question.getQuestion(from: $0)
                    })
                    //next page
                    self.page+=1
                    self.tableView.reloadData()
                }) { (error) in
                    print("Failed to fetch question batch")
                }
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            questions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK - Search delegate methods
    
    func updateSearchResults(for searchController: UISearchController) {
        //clean filter results
        self.filteredQuestions.removeAll()
        
        let searchText:String=searchController.searchBar.text!
        
        BRAPI.sharedInstance.getAllQuestions(kQuestionsPerPage, 0, searchText, success: { (response) in
            self.filteredQuestions=(response["questions"] as! Array<[String:Any?]>).flatMap{
                Question.getQuestion(from: $0)
            }
            self.filterPage=1
            self.tableView.reloadData()
        }) { (error) in
            print("Failed to fetch filtered question batch")
        }
        self.tableView.reloadData()
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSearch))
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.rightBarButtonItem = nil
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    // MARK - Share
    func shareSearch() {
        //Build sharable URL
        let searchText:String=searchController.searchBar.text!
        let escapedSearchText:String = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let searchURLToShare = "blissrecruitment://questions?question_filter=\(escapedSearchText)"
        
        //Present share screen
        let activityViewController = UIActivityViewController(activityItems: [searchURLToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
    }
}

