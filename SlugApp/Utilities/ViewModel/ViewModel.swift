//
//  ViewModelHolder.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 08/12/2025.
//

import Observation
import SwiftUI

@MainActor
protocol ViewModel: Observable {
    associatedtype ViewType: View

    func buildView() -> ViewType
}
