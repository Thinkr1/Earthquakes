//
//  SettingsView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 29/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("pastSelect") private var pastSelect: Bool = true
    @AppStorage("historicalSelect") private var historicalSelect: Bool = true
    @AppStorage("dataRange") private var dataRange: Int = 0
    @AppStorage("resultsPerPage") private var resultsPerPage: Int = 25
    
    private let dataRangeOptions = ["Past Day", "Past Week", "Past Month"]
    private let resultsOptions = [25, 50, 100, 200]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Show:")
                    .padding(.leading)
                
                Toggle("Past \(dataRangeOptions[dataRange])", isOn: $pastSelect)
                    .toggleStyle(.checkbox)
                    .onChange(of: pastSelect, initial: false) { _,_ in
                        if !pastSelect && !historicalSelect { pastSelect = true }
                    }
                
                Toggle("Historical", isOn: $historicalSelect)
                    .toggleStyle(.checkbox)
                    .onChange(of: historicalSelect, initial: false) { _,_ in
                        if !pastSelect && !historicalSelect { historicalSelect = true }
                    }
            }
            .padding(.horizontal)
            
            Picker("Data range:", selection: $dataRange) {
                ForEach(0..<dataRangeOptions.count, id: \.self) { index in
                    HStack {
                        Text(dataRangeOptions[index])
                        if index != 0 {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                        }
                    }
                    .tag(index)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal)
            
            Picker("Search results:", selection: $resultsPerPage) {
                ForEach(resultsOptions, id: \.self) { option in
                    Text("\(option)").tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            Text("Currently showing \(resultsPerPage) results in search suggestions")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack(alignment: .center, spacing: 10) {
                if #available(macOS 15.0, *) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .symbolEffect(.wiggle.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
                } else {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
                Text("Due to its extensive size, data may take more time to load")
                    .font(.footnote)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .frame(maxWidth: 350, maxHeight: 200)
    }
}
