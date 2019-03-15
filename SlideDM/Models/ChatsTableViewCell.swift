//
//  ChatsTableViewCell.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/17/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {

    // User Interface
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var greetingTagTextView: UITextView!
    @IBOutlet weak var notificationBar: UIView!
    
    // True when user is up to date with all messages
    var read: Bool = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
