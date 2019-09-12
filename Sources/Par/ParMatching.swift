//  ParMatching.swift
//  Par
//
//  Created by warren on 8/5/17.
//  Copyright © 2017 Muse Dot Company
//  License: Apache 2.0 - see License file

import Foundation

/// An array of `[ParAny]`, which can reduce a single suffix
public class ParMatching {

    public var parAnys = [ParAny]()
    var count = 0
    var ok = false

    var value: String? {
        get {
            if ok, let last = parAnys.last {
                return last.value
            }
            return nil
        }
    }
    public var parLast: ParAny? {
        get {
            if ok, let last = parAnys.last {
                return last
            }
            return nil
        }
    }

    init(_ parAny_:ParAny? = nil, ok ok_: Bool = false ) {
        if let parAny = parAny_ {
            parAnys.append(parAny)
        }
        ok = ok_
    }
    init(_ parAnys_:[ParAny], ok ok_: Bool = false ) {
        parAnys = parAnys_
        ok = ok_
    }


    /// add a sub ParMatching to this ParMatching
    func add (_ matching:ParMatching?) -> Bool {

        if  let matching = matching,
            let parLast = matching.parLast {

                add(parLast)
                return true
        }
        return false
    }

    /// add a parAny to this ParMatching
    func add (_ parAny: ParAny) {

        if !(parAny.node?.ignore ?? false) {
            parAnys.append(parAny)
        }
    }

    /// return parAny with fewest hops
    func bestCandidate() -> ParMatching {
        if parAnys.count == 0 {
            return ParMatching(nil, ok: false)
        }
        var bestParAny = parAnys.first!
        for parAny in parAnys {
            if parAny.hops < bestParAny.hops {
                bestParAny = parAny
            }
        }
        return ParMatching(bestParAny, ok: true)
    }

    /// Reduce anys
    func reduceFound(_ node: ParNode,_ isName:Bool = false) -> ParMatching {
        
        if !ok { return ParMatching(nil, ok: false) }
        
        switch parAnys.count {

        case 0: return ParMatching(ParAny(node,nil), ok: true)

        case 1:
            if  let parFirst = parAnys.first,
                let parNode = parFirst.node {

                switch  parNode.parOp  {

                case .def,.and,.or:

                    if isName, parNode.id != node.id {
                        return ParMatching(ParAny(node,[parFirst]), ok: true)
                    }
                    else {
                         return ParMatching(parFirst, ok: true)
                    }
                case .match:

                    return ParMatching(parFirst, ok: true)

                case .quo,.rgx:

                    return ParMatching(ParAny(node, parFirst.value, parFirst.hops), ok: true)
                }
            }

        default: break
        }

        // 
        var hasPromotePars = false
        var promotedNextPars = [ParAny]()
        for parAny in parAnys {
            if let promotePars = promoteNextPars(parAny) {
                hasPromotePars = true
                promotedNextPars.append(contentsOf: promotePars)
            }
            else {
                promotedNextPars.append(parAny)
            }
        }
        if hasPromotePars {
            parAnys = promotedNextPars
        }

        // sum up hops for chidren
        var hops = 0
        for parAny in parAnys {
            hops += parAny.hops
        }
        let parAny = ParAny(node,parAnys,hops)
        return ParMatching(parAny, ok: true)
    }

    /// Accommodate a graph like this, example:
    ///
    /// ParNode("or",[ParNode("and"),...
    ///            ParNode("+",[ParNode("\"|\""), ...
    ///                      ParNode("and")])]), ...
    ///
    /// which splits ParNode("+",[]) into (.and,.many,"")
    /// So, the node.pattern is ""
    ///
    /// During a parse, the "" ParNode can contain a subarray,
    /// so promote it to the same level as its siblings
    ///
    /// for example, convert:
    ///     or:(path:show, (path:hide, path:setting, path:clear))
    /// to  or:(path:show, path:hide, path:setting, path:clear)

    func promoteNextPars(_ parAny:ParAny) -> [ParAny]? {
        if  parAny.node?.pattern == "",
            parAny.value == nil {

            return parAny.nextPars
        }
        return nil
    }
}
