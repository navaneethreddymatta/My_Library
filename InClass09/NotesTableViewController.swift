//
//  NotesTableViewController.swift
//  InClass09
//
//  Created by student on 8/2/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


protocol UpdateNoteDelegate {
    func deleteNote()
}


class NotesTableViewController: UITableViewController, UpdateNoteDelegate {
    var book:Book?
    var curUser = FIRAuth.auth()?.currentUser
    var ref = FIRDatabase.database().reference()
    var notes = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        ref.child("Users").child(curUser!.uid).child("notebooks").child((self.book?.key)!).child("notes").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            self.notes.removeAll()
            let enumerator = snapshot.children
            while let note = enumerator.nextObject() as? FIRDataSnapshot {
                let nName = note.value!["name"] as? String
                let nDate = note.value!["createdDate"] as? String
                let noteObj = Note(name:nName!,Date:nDate!, key: note.key)
                self.notes.append(noteObj)
            }
            self.tableView.reloadData()
            self.tableView.estimatedRowHeight = 50
            self.tableView.rowHeight = UITableViewAutomaticDimension
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("noteCell", forIndexPath: indexPath)

        let myNote = notes[indexPath.row]
        
        if let myCell = cell as? NoteTableViewCell {
            myCell.myNote = myNote
            myCell.myBook = book
            myCell.tbl = tableView
            myCell.delegateProp = self
        }

        return cell
    }
    

    @IBAction func addNotes(sender: AnyObject) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "New Note", message: "Enter New Post Text", preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "Note Text"
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
                    self!.ref.child("Users").child((self!.curUser!.uid)).child("notebooks").child((self?.book?.key)!).child("notes").childByAutoId().setValue(["name": enteredText!,"createdDate": dateString])
                    self!.tableView.reloadData()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {[weak self] (paramAction:UIAlertAction!) in })
        
        alertController?.addAction(okAction)
        alertController?.addAction(cancelAction)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func deleteNote() {
        
    }
}

struct Note {
    let name: String
    let Date: String
    let key: String
}
