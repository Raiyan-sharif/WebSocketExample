//
//  ExtensionString.swift
//  PockeTalk
//

import UIKit
extension String {

    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8),
                                          options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return  nil
        }
    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }

    func isValidEmail() -> Bool {
        // MARK: - Check string format
        var isValid : Bool = true
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: self) == false {
            //Mail is wrong format
            isValid = false
        }
        return isValid
    }


    var isAlphanumericWithWhiteSpace: Bool {
        var result: Bool = false
        if self.isEmpty == true { result = true }
        else {
            let regEx: String = "[a-zA-Z0-9\\s]+"
            let predicate: NSPredicate = NSPredicate(format:"SELF MATCHES %@", regEx)
            result = predicate.evaluate(with: self)
        }
        return result
    }

    var isAlphanumeric: Bool {
        var result: Bool = false
        if self.isEmpty == true { result = true }
        else {
            let regEx: String = "[a-zA-Z0-9]+"
            let predicate: NSPredicate = NSPredicate(format:"SELF MATCHES %@", regEx)
            result = predicate.evaluate(with: self)
        }
        return result
    }


    // Localized string
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }

    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    func getISO_8601FormattedDateString(from string: String) -> String? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: kDateFormatterLocale)
        let date = dateFormatter.date(from: string)

        if let date = date {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let resultDate = dateFormatter.string(from: date)
            return resultDate
        } else {
            return nil
        }
    }

    func getISO_8601FormattedNotificationDate(from string: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: kDateFormatterLocale)
        let date = dateFormatter.date(from: string)
        return date ?? Date()
    }

    func getISO_8601FormattedDate(from string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: kDateFormatterLocale)
        let date = dateFormatter.date(from: string) ?? Date()
        return date
    }

    // Convert string to date
    func getFormattedDate(formatter: String) -> Date? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        dateFormatterGet.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return dateFormatterGet.date(from: self)
    }

    // Deleting suffix
    func deleteSuffix(suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }

    // Convert String to dates
    func getDateFromString(formatter: String) -> Date? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = formatter
        dateFormatterPrint.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return dateFormatterPrint.date(from: self)
    }

    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}
