//
//  View+if.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


extension View {
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            then(self)
        } else {
            elseTransform(self)
        }
    }
}

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Binding<Bool>,
        transform: (Self) -> Content
    ) -> some View {
        if condition.wrappedValue {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Binding<Bool>,
        then: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition.wrappedValue {
            then(self)
        } else {
            elseTransform(self)
        }
    }
}
