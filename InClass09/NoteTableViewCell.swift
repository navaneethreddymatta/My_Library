//
//  NoteTableViewCell.swift
//  InClass09
//
//  Created by student on 8/2/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NoteTableViewCell: UITableViewCell {
    var myNote:Note? {
        didSet {
            noteDesc.text = myNote?.name
            noteDate.text = myNote?.Date
        }
    }
    var myBook:Book?
    var tbl:UITableView?
    var delegateProp:UpdateNoteDelegate?
    var curUser = FIRAuth.auth()?.currentUser
    var ref = FIRDatabase.database().reference()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var noteDesc: UILabel!
    @IBOutlet weak var noteDate: UILabel!
    @IBAction func deleteNote(sender: UIButton) {
        var indexPath: NSIndexPath!
        var indexPathRow = 0
        if let superview = sender.superview {
            if let cell = superview.superview as? NoteTableViewCell {
                indexPath = tbl!.indexPathForCell(cell)
                indexPathRow = indexPath.row
                self.ref.child("Users").child((self.curUser!.uid)).child("notebooks").child((self.myBook?.key)!).child("notes").child((self.myNote?.key)!).removeValue()
                delegateProp?.deleteNote()
            }
        }
    }
}
