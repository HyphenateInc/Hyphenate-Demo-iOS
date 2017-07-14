//
//  EMRealtimeSearchUtil.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/16.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit

protocol  EMRealtimeSearchUtilDelegate{
    func searchKey() -> String?
}

typealias RealtimeSearchResultsBlock = (_ results: Array<Any>?) -> Void

class EMRealtimeSearchUtil: NSObject {
    
    public var asWholeSearch :Bool = false
    
    private var source: Array<EMRealtimeSearchUtilDelegate>?
    private let searchQueue = DispatchQueue(label: "cn.realtimeSearch.queue")
    private var searchThread: Thread?
    private var result: RealtimeSearchResultsBlock?

    override init() {
        super.init()
        asWholeSearch = true
    }
    
    class func currentUtil() -> EMRealtimeSearchUtil {
        let realTimeSearchUtil = EMRealtimeSearchUtil()
        return realTimeSearchUtil
    }
    
    // MAKR: - Private
    func realTimeSearch(searchString string: String?) {
        searchThread?.cancel()
        searchThread = Thread.init(target: self, selector: #selector(searchBegin), object: string)
        searchThread?.start()
 
    }
    
    func searchBegin(searchString string: String) {
        searchQueue.async {
            if string.characters.count == 0 {
                self.result!(self.source)
            }else {
                var results = Array<Any>()
                let subStr = string.lowercased()
                for object in (self.source)! {
                    var tmpStr = ""
                    tmpStr = object.searchKey() == nil ? "" : object.searchKey()!.lowercased()
                    
                    let range = tmpStr.range(of: subStr)
                    if range != nil {
                        results.append(object)
                    }
                }
                
                self.result!(results)
            }
        }
    }
    
    public func realtimeSearch(withSource resource: Array<EMRealtimeSearchUtilDelegate>?, searchText text: String?, resultBack resultBlock: @escaping RealtimeSearchResultsBlock) {
        
        if source == nil || text == nil {
            resultBlock(source)
        }
        
        source = resource
        result = resultBlock
        
        realTimeSearch(searchString: text)
    }

    public func realTimeSearchStop() {
        searchThread?.cancel()
    }
}
