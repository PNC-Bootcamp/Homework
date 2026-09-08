//
//  Products.swift
//  SwiftUIDemo
//
//  Created by Tyler Swindell on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    var product: Product
    
    var body: some View {
        
        VStack {
            Text("Product #\(product.id)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(product.name)
                .font(.title)
                .padding(20)
            Text(product.productNumber)
                .font(.title)
                .padding(20)
            Text(product.color)
                .font(.title)
                .padding(20)
            // formatting numbers in text views https://swiftprogramming.com/format-numbers-swiftui/
            Text(product.listPrice, format: .number.precision(.fractionLength(2)))
                .font(.title)
                .padding(20)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
