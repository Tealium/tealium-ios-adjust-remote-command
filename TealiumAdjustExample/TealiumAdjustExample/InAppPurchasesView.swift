//
//  InAppPurchasesView.swift
//  TealiumAdjustExample
//
//  Created by Christina S on 2/12/21.
//

import SwiftUI

struct InAppPurchasesView: View {
    
    var body: some View {
        VStack(spacing: 30) {
            TitleView("In-App Purchases")
            TextButtonView(title: "Purchase") {
                TealiumHelper.trackEvent(title: "purchase",
                                         data: ["event_token": "ud8qwf",
                                                "order_id": "ord\(Int.random(in: 1...10000))",
                                                "order_total": Double.random(in: 1.0...20.0).round,
                                                "conversion_value": Int.random(in: 1...12)])
            }
            TextButtonView(title: "Subscription") {
                TealiumHelper.trackEvent(title: "subscribe",
                                         data: ["event_token": "880fg0",
                                                "order_id": "ord\(Int.random(in: 1...10000))",
                                                "order_total": Double.random(in: 1.0...20.0).round,
                                                "order_currency": "USD",
                                                "sales_region": "US",
                                                "appstore_receipt_data": Data(),
                                                "customer_id": "cust123",
                                                "customer_is_member": true,
                                                "conversion_value": Int.random(in: 1...12)])
            }
            TextButtonView(title: "Track Ad Revenue") {
                TealiumHelper.trackEvent(title: "ad_revenue",
                                         data: ["ad_revenue_source": "someAdVendor",
                                                "campaign": "spring123",
                                                "ad_uuid": UUID().uuidString])
            }
        }
    }
}

struct InAppPurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchasesView()
    }
}
