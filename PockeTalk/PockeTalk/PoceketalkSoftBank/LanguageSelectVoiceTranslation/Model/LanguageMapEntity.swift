//
//  LanguageMapTable.swift
//  PockeTalk
//

class LanguageMapEntity: BaseEntity {
    var textCode: String?
    var textCodeTr: String?
    var textValueOne: String?
    var textValueTwo: String?
    var textValueThree: String?
    var textValueFour: String?
    var textValueFive: String?
    var textValueSix: String?
    var textValueSeven: String?

    init(id: Int64?, textCode: String, textCodeTr: String?, textValueOne: String?, textValueTwo: String?, textValueThree: String?, textValueFour: String?, textValueFive: String?, textValueSix: String?, textValueSeven: String?) {
        self.textCode = textCode
        self.textCodeTr = textCodeTr
        self.textValueOne = textValueOne
        self.textValueTwo = textValueTwo
        self.textValueThree = textValueThree
        self.textValueFour = textValueFour
        self.textValueFive = textValueFive
        self.textValueSix = textValueSix
        self.textValueSeven = textValueSeven
        super.init(baseId: id)
    }
}
