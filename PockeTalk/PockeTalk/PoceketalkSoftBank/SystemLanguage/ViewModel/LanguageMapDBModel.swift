//
//  LanguageMapDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.
//

import SQLite

class LanguageMapDBModel: BaseDBModel {
    let TABLE_NAME = "LanguageMapTable"

    let textCode: Expression<String>
    let textCodeTr: Expression<String>
    let textValueOne: Expression<String>
    let textValueTwo: Expression<String>
    let textValueThree: Expression<String>
    let textValueFour:  Expression<String>
    let textValueFive: Expression<String>
    let textValueSix: Expression<String>
    let textValueSeven: Expression<String>

    init() {
        self.textCode = Expression<String>("txt_code")
        self.textCodeTr = Expression<String>("txt_code_tr")
        self.textValueOne = Expression<String>("txt_value_one")
        self.textValueTwo = Expression<String>("txt_value_two")
        self.textValueThree = Expression<String>("txt_value_three")
        self.textValueFour = Expression<String>("txt_value_four")
        self.textValueFive = Expression<String>("txt_value_five")
        self.textValueSix = Expression<String>("txt_value_six")
        self.textValueSeven = Expression<String>("txt_value_seven")
        super.init(id: Expression<Int64>("id"), table: Table(TABLE_NAME))
    }

    func createTable() throws {
        do {
            let createTableQueryString = table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(textCode)
                t.column(textCodeTr)
                t.column(textValueOne)
                t.column(textValueTwo)
                t.column(textValueThree)
                t.column(textValueFour)
                t.column(textValueFive)
                t.column(textValueSix)
                t.column(textValueSeven)
            }

            try createTable(queryString: createTableQueryString)

        } catch _ {
            // Error thrown when table exists
        }
    }

    func insert(item: BaseEntity) throws -> Int64 {
        if let languageMapTable = item as? LanguageMapEntity {
            let insertStatement = table.insert(textCode <- languageMapTable.textCode!, textCodeTr <- languageMapTable.textCodeTr!, textValueOne <- languageMapTable.textValueOne!, textValueTwo <- languageMapTable.textValueTwo!, textValueThree <- languageMapTable.textValueThree!, textValueFour <- languageMapTable.textValueFour!, textValueFive <- languageMapTable.textValueFive!, textValueSix <- languageMapTable.textValueSix!, textValueSeven <- languageMapTable.textValueSeven! )

            _ = try? insert(queryString: insertStatement)
        }
        throw DataAccessError.Nil_In_Data
    }

    func delete (item: BaseEntity) throws -> Void {
        guard let languageMapTable = item as? LanguageMapEntity else {
            return
        }

        if let findId = languageMapTable.id {
            try delete(idToDelte: findId)
        }

    }

    func find(idToFind: Int64) throws -> BaseEntity? {
        let items = try find(findId: idToFind)
        for item in  items {
            return LanguageMapEntity.init(id: item[id], textCode: item[textCode], textCodeTr: item[textCodeTr], textValueOne: item[textValueOne], textValueTwo: item[textValueTwo], textValueThree: item[textValueThree], textValueFour: item[textValueFour], textValueFive: item[textValueFive], textValueSix: item[textValueSix], textValueSeven: item[textValueSeven])
        }

        return nil

    }

     func findAllEntities() throws -> [BaseEntity]? {
        var retArray = [BaseEntity]()
        let items = try findAll()
        for item in items {
            retArray.append(LanguageMapEntity.init(id: item[id], textCode: item[textCode], textCodeTr: item[textCodeTr], textValueOne: item[textValueOne], textValueTwo: item[textValueTwo], textValueThree: item[textValueThree], textValueFour: item[textValueFour], textValueFive: item[textValueFive], textValueSix: item[textValueSix], textValueSeven: item[textValueSeven]))
        }

        return retArray
    }
}
