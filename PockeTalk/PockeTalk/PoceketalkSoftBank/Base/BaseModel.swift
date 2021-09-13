//
//  BaseModel.swift
//  PockeTalk
//
//

import Foundation

//This the base class of all Model class
public class BaseModel : NSObject {
    var mDelegate : BaseDelegate?
    var mBaseDataList : [BaseData] = []
    
    func notify(notifyObject : BaseData) {
        if mDelegate != nil {
            mDelegate?.update(data : notifyObject)
        }
    }
    
    func getCount() -> Int {
        return mBaseDataList.count
    }
    
    func addItem(item : BaseData) {
        mBaseDataList.append(item)
    }
    
    func addAtPosition(item : BaseData, at position : Int) {
        mBaseDataList.insert(item, at: position)
    }
    
    func remove(at index : Int) {
        mBaseDataList.remove(at: index)
    }
    
    func getItem(at index : Int) -> BaseData {
        return mBaseDataList[index]
    }
    
    func getList() -> [BaseData] {
        return mBaseDataList
    }
}
