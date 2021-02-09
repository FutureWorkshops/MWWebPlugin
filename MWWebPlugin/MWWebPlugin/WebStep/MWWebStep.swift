//
//  MWWebStep.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWWebStep: ORKStep {
    
    let url: URL
    
    init(identifier: String, url: URL) {
        self.url = url
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func stepViewControllerClass() -> AnyClass {
        return MWWebViewController.self
    }
}

extension MWWebStep: MobileWorkflowStep {
    public static func build(step: StepInfo, services: MobileWorkflowServices) throws -> ORKStep {
        if let urlString = step.data.content["url"] as? String, let url = URL(string: urlString) {
            return MWWebStep(identifier: step.data.identifier, url: url)
        } else {
            throw NSError(domain: "io.mobileworkflow.web", code: 0, userInfo: [NSLocalizedDescriptionKey:"URL missing from the JSON"])
        }
    }
}
