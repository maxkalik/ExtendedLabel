//
//  ContentView.swift
//  ExtendedLabel
//
//  Created by Maksim Kalik on 26/05/2022.
//

import SwiftUI

let html = """
    <h1>Hello, worlds!</h1>
    <p>You can create an NSAttributedString directly from <a href="http://citadele.lv">HTML</a>, including support for a wide <i>range of formatting</i>, using a special <u>initializer</u> and passing in <b>NSAttributedString.DocumentType.html</b> for your document\n<a href="http://maxkalik.com">some link</a> type.</p>
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
