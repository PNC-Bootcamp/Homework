//
//  Products.swift
//  SwiftUIDemo
//
//  Created by Tyler Swindell on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    
    @State private var productList: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(productList) { prod in
                NavigationLink(value: prod) {
                    HStack {
                        Text(prod.name)
                        Text(prod.color)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            .navigationTitle("Products")
            .navigationDestination(for: Product.self ) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
        }
        .task {
            loadData()
        }
    }
    
    func loadData() {
        // Normally you'd load API data here
        productList = [
            Product(id: 1, name: "Product1", productNumber: "PRD12340", color: "Green", listPrice: 1.50),
            Product(id: 2, name: "Product2", productNumber: "PRD12341", color: "Brown", listPrice: 12.00),
            Product(id: 3, name: "Product3", productNumber: "PRD12342", color: "Yellow", listPrice: 6.15),
            Product(id: 4, name: "Product4", productNumber: "PRD12343", color: "Blue", listPrice: 5.99),
            Product(id: 5, name: "Product5", productNumber: "PRD12344", color: "Red", listPrice: 1.01)
        ]
    }
}

#Preview {
    ProductList()
}
