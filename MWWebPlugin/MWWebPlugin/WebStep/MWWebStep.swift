//
//  MWWebStep.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWWebStep: ORKStep {
    
    override init(identifier: String) {
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
        return MWWebStep(identifier: step.data.identifier)
    }
}
