//
//  ContentView.swift
//  ExtendedLabel
//
//  Created by Maksim Kalik on 26/05/2022.
//

import SwiftUI

let html = """
    <h1>Message Title</h1>
    <p>The message has <a href="http://maxkalik.com">HTML link</a>. The text supports <i>italic format</i> and <u>underlined style</u> and <b>bold text</b>. All this message could be wrapped in paragraph tag and can include <a href="http://apple.com">multiple links<a/>.</p>
"""


struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Text("Hello")
                Spacer()
            }
            ExpandedMessageView(
                text: html,
                readMore: "Read More",
                readLess: "Read Less",
                closeAction: { print("closed") }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
