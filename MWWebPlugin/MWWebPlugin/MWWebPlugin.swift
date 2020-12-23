//
//  MWWebPlugin.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public struct MWWebPlugin: MobileWorkflowPlugin {
    public static var allStepsTypes: [MobileWorkflowStepType] {
        return MWWebStepType.allCases
    }
}

public enum MWWebStepType: String, MobileWorkflowStepType, CaseIterable {
    
    case web = "io.mobileworkflow.WebView"
    
    public var typeName: String {
        return self.rawValue
    }
    
    public var stepClass: MobileWorkflowStep.Type {
        switch self {
        case .web: return MWWebStep.self
        }
    }
}
