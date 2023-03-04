//
//  StepController.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 04/03/2023.
//  Copyright © 2023 Tianxiang Song. All rights reserved.
//

import UIKit
import CoreML

@available(iOS 13.0.0, *)
class StepController {
    
    var nc = NodeController()
    var autoStepTimer = Timer()
    var model = try? LEGOStepClassifier(configuration: MLModelConfiguration())
    var tempView = UIImageView()
    
    init(nc: NodeController) {
        self.nc = nc
    }
}
