//
//  MWWebStep.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWWebStep: MWStep {
    
    let url: URL
    
    init(identifier: String, url: URL) {
        self.url = url
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWWebViewController(step: self)
    }
}

extension MWWebStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"]
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        guard let urlString = stepInfo.data.content["url"] as? String, let url = URL(string: urlString) else {
            throw ParseError.invalidStepData(cause: "Missing or malformed 'url' property")
        }
        return MWWebStep(identifier: stepInfo.data.identifier, url: url)
    }
}
