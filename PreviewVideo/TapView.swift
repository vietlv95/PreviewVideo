//
//  TapView.swift
//  PreviewVideo
//
//  Created by VietLV on 10/12/20.
//

import UIKit

class TapView: UIControl {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.animate(alpha: 0.6)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.animate(alpha: 1)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.animate(alpha: 1)
    }

    private func animate(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
        }
    }
}
