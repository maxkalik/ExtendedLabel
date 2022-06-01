//
//  Testab.swift
//  ExtendedLabel
//
//  Created by Maksim Kalik on 01/06/2022.
//

import UIKit
import SwiftUI

struct SearchBarUIViewRepresentable: UIViewRepresentable {
    @Binding var searchText: String
    private var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        var searchBar: UISearchBar? = nil
        var placeholder: String? = nil
        var keyboardType: UIKeyboardType = .default
        var coordinator: Coordinator? = nil
    }
    
    init(binding searchText: Binding<String>) {
        _searchText = searchText
        makeCoordinator()
    }
    
    func placeholder(_ placeholder: String) -> Self {
        mutatingWrapper.placeholder = placeholder
        return self
    }
    
    func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        mutatingWrapper.keyboardType = keyboardType
        return self
    }
    
    func onSearchButtonClicked(delegate: @escaping (String) -> ()) -> Self {
        mutatingWrapper.coordinator?.onSearchButtonClickedDelegate = delegate
        return self
    }
    
    func onSearchTextChanged(delegate: @escaping (String) -> ()) -> Self {
        mutatingWrapper.coordinator?.onSearchTextChangedDelegate = delegate
        return self
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var searchText: String
        var onSearchButtonClickedDelegate: ((String) -> ())? = nil
        var onSearchTextChangedDelegate: ((String) -> ())? = nil

        init(binding searchText: Binding<String>) {
            _searchText = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: false)
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
            if let delegate = onSearchTextChangedDelegate {
                delegate(searchText)
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            if let delegate = onSearchButtonClickedDelegate {
                delegate(searchText)
            }
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }

    @discardableResult func makeCoordinator() -> SearchBarUIViewRepresentable.Coordinator {
        if mutatingWrapper.coordinator == nil {
            mutatingWrapper.coordinator = Coordinator(binding: $searchText)
        }
        return mutatingWrapper.coordinator!
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBarUIViewRepresentable>) -> UISearchBar {
        if mutatingWrapper.searchBar == nil {
            mutatingWrapper.searchBar = UISearchBar(frame: .zero)
            mutatingWrapper.searchBar!.delegate = makeCoordinator()
            mutatingWrapper.searchBar!.placeholder = mutatingWrapper.placeholder
            mutatingWrapper.searchBar!.searchBarStyle = .minimal
            mutatingWrapper.searchBar!.autocapitalizationType = .none
            mutatingWrapper.searchBar!.keyboardType = mutatingWrapper.keyboardType
        }
        return mutatingWrapper.searchBar!
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBarUIViewRepresentable>) {
        uiView.text = searchText
    }
}
