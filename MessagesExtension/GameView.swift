//
//  GameView.swift
//  TicTacToe
//
//  Created by Colin Witkamp on 7/29/16.
//  Copyright © 2016 cw. All rights reserved.
//

import UIKit

class GameView: UICollectionView {
    var game: TicTacToe?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
