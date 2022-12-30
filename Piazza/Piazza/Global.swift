//
//  Global.swift
//  Piazza
//
//  Created by Jared Rader on 12/29/22.
//

import Foundation
import Turbo

struct Global {
    static let pathConfiguration = PathConfiguration(
        sources:
            [
                .file(
                    Bundle.main.url(
                        forResource: "path_configuration",
                        withExtension: "json"
                    )!)
            ]
    )
}
