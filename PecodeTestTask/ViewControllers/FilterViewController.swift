//
//  FilterViewController.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit


protocol FilterViewControllerDelegate {
    func filterParametersChanged(filter: Filter)
}


class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var isCountryListOpen: Bool = false
    
    var isCategoryListOpen: Bool = false
    
    var isSourceListOpen: Bool = false

    var selectedRowInPickers1: [Int: Int] = [ : ]
    var selectedRowInPickers2: [Int: Int] = [ : ]
    
    var delegate: FilterViewControllerDelegate?

    var settings = Settings()
    
    var filter = Filter()
    
    var filterType: FilterType = .countryAndCategory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSegmentControl()
        
        filter = settings.selectedFilter
        
        selectedRowInPickers1[0] = Int(Country.allCases.firstIndex { $0 == filter.country } ?? 0)
        selectedRowInPickers1[1] = Int(Category.allCases.firstIndex { $0 == filter.category } ?? 0)
        selectedRowInPickers2[0] = Int(settings.allSources.firstIndex { $0 == filter.source } ?? 0)
        
        if filter.category == nil && filter.country == nil {
            segmentControl.selectedSegmentIndex = 1
            segmentControlDidChange(segmentControl)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TextFieldAndButtonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldAndButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: DropDownPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: DropDownPickerTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor.systemGroupedBackground
        tableView.backgroundColor = UIColor.systemGroupedBackground
    }
    
    @IBAction func didPressSave(_ sender: UIBarButtonItem) {
    
        delegate?.filterParametersChanged(filter: filter)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func segmentControlDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterType = .countryAndCategory
            tableView.reloadData()
        case 1:
            filterType = .source
            tableView.reloadData()
        default:
            break
        }
    }
    
    private func setupSegmentControl() {
        let titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterType == .countryAndCategory {
            if section == 0 {
                return isCountryListOpen ? 2 : 1
            } else if section == 1 {
                return isCategoryListOpen ? 2 : 1
            }
        } else {
            return isSourceListOpen ? 2 : 1
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterType == .source ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 150 : 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterType == .countryAndCategory {
            return ["Select the country for which you want to receive news", "Select a news category"][section]
        } else {
            return "Select the information source"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
            guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: indexPath) as? TextFieldAndButtonTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            var text: String?
  
            
            var placeholder = ""
            if filterType == .countryAndCategory {
                text = [filter.country?.getFullName(), filter.category?.rawValue][indexPath.section]
                placeholder = ["Country", "Category"][indexPath.section]
            } else {
                text = (filter.source?.name ?? filter.source?.id) ?? ""
                placeholder = "Source of inforamtion"
            }
            
            newLessonCell.configureCell(text: text, placeholder: placeholder)
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

            var dataArray: [String] = []
            if filterType == .countryAndCategory {
                if indexPath.section == 0 {
                    dataArray = Country.allCases.map({ $0.getFullName() })
                } else if indexPath.section == 1 {
                    dataArray = Category.allCases.map({ $0.rawValue })
                }
            } else {
                dataArray = settings.allSources.map( { (($0.name ?? $0.id) ?? "") })
            }
         
            cellWithOnePicker.dataArray = dataArray
            cellWithOnePicker.delegate = self
            if filterType == .countryAndCategory {
                cellWithOnePicker.previousSelectedIndex = selectedRowInPickers1[indexPath.section] ?? 0
            } else {
                cellWithOnePicker.previousSelectedIndex = selectedRowInPickers2[indexPath.section] ?? 0
            }
            cellWithOnePicker.selectionStyle = .none
            
            return cellWithOnePicker
        }
        
    }
}


extension FilterViewController: TextFieldAndButtonTableViewCellDelegate {
    
    func userDidPressShowDetails(at indexPath: IndexPath) {
        
        var switcherValue = false
        
        if filterType == .countryAndCategory {
            if indexPath.section == 0 {
                isCountryListOpen.toggle()
                switcherValue = isCountryListOpen
            } else if indexPath.section == 1 {
                isCategoryListOpen.toggle()
                switcherValue = isCategoryListOpen
            }
        } else {
            isSourceListOpen.toggle()
            switcherValue = isSourceListOpen
        }
        
        if switcherValue {
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        }
    }
}


extension FilterViewController: DropDownPickerTableViewCellDelegate {
    
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int) {
        guard let cell = tableView.cellForRow(at: fatherIndexPath) as? TextFieldAndButtonTableViewCell else {
            assertionFailure("Invalid indexPath")
            return
        }
        
        if filterType == .countryAndCategory {
            selectedRowInPickers1[fatherIndexPath.section] = inPickerRow

            filter.source = nil
            if fatherIndexPath.section == 0 {
                filter.country = Country.allCases[inPickerRow]
            } else if fatherIndexPath.section == 1 {
                filter.category = Category.allCases[inPickerRow]
            }
        } else {
            selectedRowInPickers2[fatherIndexPath.section] = inPickerRow
            filter.category = nil
            filter.country = nil
            filter.source = settings.allSources[inPickerRow]
        }
        
        cell.configureCell(text: text, placeholder: nil)
    }
    
}
