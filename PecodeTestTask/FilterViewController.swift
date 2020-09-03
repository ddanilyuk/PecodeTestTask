//
//  FilterViewController.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit


protocol FilterViewControllerDelegate {
    func filterParametersChanged()
}


class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var isCountryListOpen: Bool = false
    
    var isCategoryListOpen: Bool = false
    
    var isSourceListOpen: Bool = false
    
    var countrySelected: Country = .ua
    
    var categorySelected: Category = .allCategories

    let headersOfSections: [Int: String] = [
        0: "You can`t mix country with source",
        1: "You can`t mix category with source"
//        2: "Choose source information",
    ]
    
    let placeholdersOfSections: [Int: String] = [
        0: "Country",
        1: "Category",
        2: "Source",
    ]
    
    var selectedRowInPickers: [Int: Int] = [ :
//        0 : 2,
//        1 : 3
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        selectedRowInPickers[0] = Int(Country.allCases.firstIndex { $0 == .ua } ?? 0)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TextFieldAndButtonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldAndButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: DropDownPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: DropDownPickerTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor.systemGroupedBackground
        tableView.backgroundColor = UIColor.systemGroupedBackground
    }
    

}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isCountryListOpen ? 2 : 1
        } else if section == 1 {
            return isCategoryListOpen ? 2 : 1
        } else if section == 2 {
            return isSourceListOpen ? 2 : 1
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 150 : 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headersOfSections[section] == nil ? 20 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersOfSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
            guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: indexPath) as? TextFieldAndButtonTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            var text: String?
            if indexPath.section == 0 {
                text = countrySelected.getFullName()
            } else if indexPath.section == 1 {
                text = categorySelected.rawValue
            }
            
            newLessonCell.configureCell(text: text, placeholder: placeholdersOfSections[indexPath.section])

            newLessonCell.indexPath = IndexPath(row: 0, section: indexPath.section)
            newLessonCell.delegate = self
            newLessonCell.selectionStyle = .none
            newLessonCell.mainTextField.isEnabled = false
            
            return newLessonCell

        } else {
            guard let cellWithOnePicker = tableView.dequeueReusableCell(withIdentifier: DropDownPickerTableViewCell.identifier, for: indexPath) as? DropDownPickerTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            cellWithOnePicker.fatherIndexPath = IndexPath(row: 0, section: indexPath.section)
            
            //
            var dataArray: [String] = []
            if indexPath.section == 0 {
                dataArray = Country.allCases.map({ $0.getFullName() })
            } else if indexPath.section == 1 {
                
                dataArray = Category.allCases.map({ $0.rawValue })
//                dataArray.insert("All categories", at: 0)
            } else if indexPath.section == 2 {
                dataArray = ["BBC", "Ria", "Google"]
            }
//            dataArray.insert("Default", at: 0)
            
            cellWithOnePicker.dataArray = dataArray
            cellWithOnePicker.delegate = self
            cellWithOnePicker.previousSelectedIndex = selectedRowInPickers[indexPath.section] ?? 0
            cellWithOnePicker.selectionStyle = .none
            
            return cellWithOnePicker
        }
        
    }
    
    
}


extension FilterViewController: TextFieldAndButtonTableViewCellDelegate {
    
    func userDidPressShowDetails(at indexPath: IndexPath) {
        var switcherValue = false
        
        if indexPath.section == 0 {
            isCountryListOpen.toggle()
            switcherValue = isCountryListOpen
        } else if indexPath.section == 1 {
            isCategoryListOpen.toggle()
            switcherValue = isCategoryListOpen
        } else if indexPath.section == 2 {
            isSourceListOpen.toggle()
            switcherValue = isSourceListOpen
        } else {
            return
        }
        
        if switcherValue {
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        }
    }
    
    func userChangeTextInTextField(at indexPath: IndexPath, text: String) {
        print("")
    }
    
    
}

extension FilterViewController: DropDownPickerTableViewCellDelegate {
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int) {
        guard let cell = tableView.cellForRow(at: fatherIndexPath) as? TextFieldAndButtonTableViewCell else {
            assertionFailure("Invalid indexPath")
            return
        }
        userChangeTextInTextField(at: fatherIndexPath, text: text)
        selectedRowInPickers[fatherIndexPath.section] = inPickerRow
        cell.configureCell(text: text, placeholder: nil)
    }
}
