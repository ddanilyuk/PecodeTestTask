//
//  SourceTableViewCell.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 06.09.2020.
//

import UIKit

class SourceTableViewCell: UITableViewCell {

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var sourceCheckmarkImageView: UIImageView!
    
    
    var isSourceSelected: Bool = false {
        didSet {
            /// Using SF Symols
            sourceCheckmarkImageView.image = isSourceSelected ? UIImage(systemName: "checkmark") : UIImage()
        }
    }
    
    var source: Source? {
        didSet {
            sourceLabel.text = source?.name ?? source?.id
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
