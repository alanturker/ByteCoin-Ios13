//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(_ coinManager: CoinManager, price: CoinModel)
    func didFailWithError(error:Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8058ADDE-B565-4F4A-9CE7-BDE769CE97A4"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func fetchBTCRate(currencySelection: String) {
        let urlString = "https://rest.coinapi.io/v1/exchangerate/BTC/\(currencySelection)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func getCoinPrice(for currency: String) {
        
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let price = self.parseJSON(safeData) {
                        delegate?.didUpdatePrice(self, price: price)
                    }
                }
            }
            task.resume()
            
        }
        
    }
    
    func parseJSON(_ data: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            let price = CoinModel(id: lastPrice)
            return price
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
