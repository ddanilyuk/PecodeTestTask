//
//  NewLessonTalbleViewCellWithTextField.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit


protocol TextFieldAndButtonTableViewCellDelegate {
    func userDidPressShowDetails(at indexPath: IndexPath)
}


class TextFieldAndButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainTextField: UITextField!
    
    @IBOutlet weak var detailsButton: UIButton!
    
    var delegate: TextFieldAndButtonTableViewCellDelegate?

    var isDetailsOpen: Bool = false
    
    /// Index path of cell. Must be changed when table vie create new cell.
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Configure text field with text or placeholder
    func configureCell(text: String? = nil, placeholder: String? = nil) {
        mainTextField.placeholder = placeholder
        mainTextField.text = text
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didPressDetails(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        delegate?.userDidPressShowDetails(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            self.detailsButton.transform = CGAffineTransform(rotationAngle: self.isDetailsOpen ? 0 : .pi / -2)
        }
        isDetailsOpen.toggle()
    }
}
