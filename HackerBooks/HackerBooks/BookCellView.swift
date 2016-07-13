//
//  BookCellView.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 13/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class BookCellView: UITableViewCell {
    
    //MARK: - Properties
    @IBOutlet weak var bookTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}