//
//  SettingsView.swift
//  Earthquakes
//
//  Created by Pierre-Louis ML on 29/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var pastSelect: Bool
    @Binding var historicalSelect: Bool
    @Binding var dataRange: Int
    
    var body: some View {
        VStack {
            //            Text("Settings")
            //                .font(.headline)
            //                .bold()
            //                .padding(.top, 10)
            HStack {
                Text("Show: ")
                    .padding()
                if #available(macOS 14.0, *) {
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $pastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: pastSelect, initial: false) {
                            if !historicalSelect && !pastSelect {
                                pastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $historicalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: historicalSelect, initial: false) {
                            if !pastSelect && !historicalSelect {
                                historicalSelect=true
                            }
                        }
                } else {
                    Toggle("Past \(dataRange==0 ? "Day" : dataRange==1 ? "Week" : "Month")", isOn: $pastSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: pastSelect) { _ in
                            if !historicalSelect && !pastSelect {
                                pastSelect=true
                            }
                        }
                    Toggle("Historical", isOn: $historicalSelect)
                        .toggleStyle(.checkbox)
                        .onChange(of: historicalSelect) { _ in
                            if !pastSelect && !historicalSelect {
                                historicalSelect=true
                            }
                        }
                }
            }.padding()
        }
        .padding(.top)
        //        .background(Color.clear.background(.regularMaterial))
        //        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        Picker("Data range: ", selection: $dataRange) {
            HStack {
                Text("Past Day")
            }.tag(0)
            HStack {
                Text("Past Week")
                Image(systemName: "exclamationmark.triangle")
            }.tag(1)
            HStack {
                Text("Past Month")
                Image(systemName: "exclamationmark.triangle")
            }.tag(2)
        }.padding(.bottom)
        HStack {
            if #available(macOS 15.0, *) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .symbolEffect(.wiggle.up.byLayer, options: .repeat(.periodic(delay: 1.0)))
            } else {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
            Text("Due to its extensive size, data may take more time to load")
        }.padding()
    }
}
