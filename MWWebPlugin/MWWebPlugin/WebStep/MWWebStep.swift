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
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        if let urlString = stepInfo.data.content["url"] as? String, let url = URL(string: urlString) {
            return MWWebStep(identifier: stepInfo.data.identifier, url: url)
        } else {
            throw NSError(domain: "io.mobileworkflow.web", code: 0, userInfo: [NSLocalizedDescriptionKey:"URL missing from the JSON"])
        }
    }
}
