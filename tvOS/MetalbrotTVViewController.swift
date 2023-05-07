//
//  TVOSViewController.swift
//  Metalbrot-Multiplatform
//
//  Created by Joss Manger on 5/7/23.
//

#if os(tvOS)

import UIKit

final class MetalbrotTVViewController: MetalbrotBaseViewController {

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        viewModel?.requestUpdate()
    }
    
}

#endif
