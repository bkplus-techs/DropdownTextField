//
//  DropDownTextField.swift
//  DropDownTextField
//
//  Created by Điệp Nguyễn on 9/14/18.
//  Copyright © 2018 BKplus. All rights reserved.
//

import Foundation

public enum DropDownMode {
	case textPicker
	case datePicker
	case textField
}

@objc public protocol DropDownTextFieldDelegate {
	@objc optional func didSelectedItem(textfield: DropDownTextField, item: String)
	@objc optional func didSelectedDate(textfield: DropDownTextField, date: Date)
	@objc optional func didSelectedDone(textfield: DropDownTextField)
}

@IBDesignable public class DropDownTextField: UITextField {
	
	// MARK: - Properties
	public var dropDownMode: DropDownMode = .textField
	
	public var currentDate: Date?{
		didSet {
			if let currentDate = currentDate{
				datePicker?.date = currentDate
				datePicker?.maximumDate = Date()
			}
		}
	}
	
	private var datePicker: UIDatePicker?
	private var pickerView: UIPickerView?
	
	weak public var dropDowndelegate: DropDownTextFieldDelegate?
	
	private var minimumDate: Date?
	private var maximumDate: Date?
	
	/*List items for DropDownModeTextPicker*/
	private var listItems = [String]()
	
	/*Mode DatePicker*/
	private var dropDownDateFormater = DateFormatter()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	fileprivate func initialize() {
		// Date format
		dropDownDateFormater.dateStyle = .medium
		dropDownDateFormater.timeStyle = .none
		
		self.inputAccessoryView = setupToolbar()
		
		setDropDownMode(mode: .textField)
	}
	
	@IBInspectable public var mode: Int = 0 {
		didSet {
			switch mode {
			case 0:
				dropDownMode = .textField
			case 1:
				dropDownMode = .datePicker
			case 2:
				dropDownMode = .textPicker
			default:
				dropDownMode = .textField
			}
		}
	}
	
	/* Public func */
	// MARK: - setup pickers
	public func setDropDownMode(mode: DropDownMode) {
		dropDownMode = mode
		switch mode {
		case .datePicker:
			self.inputView = self.setDatePicker()
		case .textPicker:
			self.inputView = self.setPickerView()
		default:
			self.inputView = nil
		}
	}
	
	public func setListItems(items: [String]) {
		switch dropDownMode {
		case .textPicker:
			listItems = items
			pickerView?.reloadAllComponents()
		default:
			break
		}
		
	}
	
	// Call this func if you has a value before
	public func setSelectItem(item: String, animated: Bool = true) {
		selectedItem(selectedItem: item, animated: false, shouldNotify: false)
	}
	
	public func setDateFormater(dFormat: DateFormatter) {
		dropDownDateFormater = dFormat
		datePicker?.locale = dropDownDateFormater.locale
	}
	
	public func setMinimumDate(minDate: Date) {
		minimumDate = minDate
		datePicker?.minimumDate = minDate
	}
	
	public  func setMaximumDate(maxDate: Date) {
		maximumDate = maxDate
		datePicker?.maximumDate = maxDate
	}
	
	public func setDefaultValue(value: String) {
		selectedItem(selectedItem: value, animated: true, shouldNotify: true)
	}
	
	public func setDatePickerMode(mode: UIDatePickerMode) {
		self.datePicker?.datePickerMode = mode
	}
	
	//MARK: Private funcs
	fileprivate func setDatePicker() -> UIDatePicker {
		if self.datePicker == nil {
			self.datePicker = UIDatePicker()
			self.datePicker?.backgroundColor = .white
			self.datePicker?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.datePicker?.datePickerMode = .dateAndTime
			self.datePicker?.addTarget(self, action: #selector(DropDownTextField.dateChanged(dPicker:)), for: .valueChanged)
		}
		
		return self.datePicker ?? UIDatePicker()
	}
	
	fileprivate func setPickerView() -> UIPickerView {
		if self.pickerView == nil {
			self.pickerView = UIPickerView()
			self.pickerView?.backgroundColor = .white
			self.pickerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			self.pickerView?.dataSource = self
			self.pickerView?.delegate = self
			self.pickerView?.showsSelectionIndicator = true
		}
		
		return self.pickerView ?? UIPickerView()
	}
	
	fileprivate func setupToolbar() -> UIView {
		let toolbar = UIToolbar()
		let btnFlexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		let btnDone = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(DropDownTextField.done))
		
		toolbar.setItems([btnFlexible, btnDone], animated: true)
		let screen = UIScreen.main.bounds
		let view = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 35))
		view.backgroundColor = UIColor.white
		toolbar.frame = view.frame
		view.addSubview(toolbar)
		return view
	}
	
	@objc private func dateChanged(dPicker: UIDatePicker) {
		selectedItem(selectedItem: self.dropDownDateFormater.string(from: dPicker.date), animated: true, shouldNotify: true)
	}
	
	fileprivate func selectedItem(selectedItem: String, animated: Bool = true, shouldNotify: Bool = true) {
		switch dropDownMode {
		case .datePicker:
			if let date = self.dropDownDateFormater.date(from: selectedItem) {
				datePicker?.setDate(date, animated: animated)
				if shouldNotify {
					dropDowndelegate?.didSelectedDate?(textfield: self, date: date)
				}
			} else {
				print("Invalid date or date format: \(selectedItem)")
			}
		case .textPicker:
			if listItems.contains(selectedItem) {
				pickerView?.selectRow(listItems.index(of: selectedItem) ?? 0, inComponent: 0, animated: animated)
				if shouldNotify {
					dropDowndelegate?.didSelectedItem?(textfield: self, item: selectedItem)
				}
			} else {
				print("Invalid text")
			}
		default:
			break
		}
	}
	
	@objc private func done() {
		self.dropDowndelegate?.didSelectedDone?(textfield: self)
		self.resignFirstResponder()
	}
}

extension DropDownTextField: UIPickerViewDataSource {
	
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return listItems.count
	}
	
	public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if row < listItems.count {
			return listItems[row]
		} else {
			return ""
		}
	}
}

extension DropDownTextField: UIPickerViewDelegate {
	
	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let text = listItems[row]
		self.selectedItem(selectedItem: text, animated: true, shouldNotify: true)
	}
}
