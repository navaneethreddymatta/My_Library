//
//  NotebooksTableViewController.swift
//  InClass09
//
//  Created by student on 8/2/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NotebooksTableViewController: UITableViewController {
    var alertController:UIAlertController?
    var curUser = FIRAuth.auth()?.currentUser
    var notebooks = [Book]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("1")
        fetchData()
    }
    
    func fetchData() {
        ref.child("Users").child(curUser!.uid).child("notebooks").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.notebooks.removeAll()
            let enumerator = snapshot.children
            while let book = enumerator.nextObject() as? FIRDataSnapshot {
                let bName = book.value!["name"] as? String
                let bDate = book.value!["createdDate"] as? String
                let bookObj = Book(name:bName!,Date:bDate!, key: book.key)
                self.notebooks.append(bookObj)
            }
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebooks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notebookCell", forIndexPath: indexPath)
        
        let myBook = notebooks[indexPath.row]
        cell.textLabel?.text = myBook.name
        cell.detailTextLabel?.text = myBook.Date
        // Configure the cell...

        return cell
    }

    @IBAction func logoutUser(sender: UIBarButtonItem) {
        try! FIRAuth.auth()?.signOut()
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("LoginStoryBoard") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    var ref = FIRDatabase.database().reference()
    
    @IBAction func addNoteBook(sender: UIBarButtonItem) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "New Notebook", message: "Enter Notebook Name", preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Notebook Name"
        })
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                if enteredText != nil && enteredText != "" {
                    let cDate = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.LongStyle
                    formatter.timeStyle = .MediumStyle
                    let dateString = formatter.stringFromDate(cDate)
                    self!.ref.child("Users").child((self!.curUser!.uid)).child("notebooks").childByAutoId().setValue(["name": enteredText!,"createdDate": dateString])
                    //self!.tableView.reloadData()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
        
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        let selectedBook = notebooks[indexPath.row]
        if let notesVC = segue.destinationViewController as? NotesTableViewController {
            notesVC.book = selectedBook
        }
    }
}

struct Book {
    let name: String
    let Date: String
    let key: String
}
