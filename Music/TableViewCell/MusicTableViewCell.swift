//
//  MusicTableViewCell.swift
//  Music
//
//  Created by Shahzaib Mumtaz on 15/09/2022.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var musicImage: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        musicView.layer.borderColor = UIColor.white.cgColor
        musicView.layer.borderWidth = 1
        musicView.layer.cornerRadius = 12
        musicView.backgroundColor = .clear
        
        musicImage.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static let identifier = "MusicTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MusicTableViewCell",
                     bundle: nil)
    }
    
}
