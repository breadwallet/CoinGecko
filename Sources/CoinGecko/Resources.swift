//
//  Resources.swift
//  
//
//  Created by Adrian Corscadden on 2020-07-05.
//

import Foundation

public enum Endpoint: String {
    case ping = "/ping"
    
    case supportedVs = "/simple/supported_vs_currencies"
    case simplePrice = "/simple/price"
    
    case coinsList = "/coins/list"
    case coinsMarketChart = "/coins/%@/market_chart"
    case coin = "/coins/%@" 
    case ohlc = "/coins/%@/ohlc"
}

public enum Resources {}

// MARK: - Ping
extension Resources {
    public static func ping<Pong>(_ callback: @escaping Callback<Pong>) -> Resource<Pong> {
        return Resource(.ping, method: .GET, completion: callback)
    }
}

// MARK: - Simple
extension Resources {
    public static func simplePrice<PriceList>(ids: [String], vsCurrency: String, options: [SimplePriceOptions], _ callback: @escaping Callback<PriceList>) -> Resource<PriceList> {
        let params = SimplePriceParams(ids: ids,
                                       vsCurrency: vsCurrency,
                                       includeMarketCap: options.contains(.marketCap),
                                       include24hrVol: options.contains(.vol),
                                       include24hrChange: options.contains(.change),
                                       includeLastUpdatedAt: options.contains(.lastUpdated))
        let parse: (Data) -> PriceList = { data in
            var result = [SimplePrice]()
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                params.ids.forEach { id in
                    guard let item = json?[id] as? [String: Any] else { print("item not found"); return }
                    if let price = SimplePrice(json: item, id: id, prefix: vsCurrency) {
                        result.append(price)
                    }
                }
            } catch let e {
                print("json error: \(e)")
            }
            return result as! PriceList
        }
        return Resource(.simplePrice, method: .GET, params: params.queryItems(), parse: parse, completion: callback)
    }
    
    public static func supported<SupportedList>(_ callback: @escaping Callback<SupportedList>) -> Resource<SupportedList> {
        return Resource(.supportedVs, method: .GET, completion: callback)
    }
}

// MARK: - Coins
extension Resources {
    
    public static func coin<CoinResponse>(currencyId: String, vs: String,
                               _ callback: @escaping (Result<CoinResponse, CoinGeckoError>) -> Void) -> Resource<CoinResponse>{
        let params = [URLQueryItem(name: "market_data", value: "true"),
                      URLQueryItem(name: "localization", value: "false"),
                      URLQueryItem(name: "tickers", value: "false"),
                      URLQueryItem(name: "community_data", value: "false"),
                      URLQueryItem(name: "developer_data", value: "false")]
        return Resource(.coin, method: .GET, pathParam: currencyId, params: params, customKey: vs, completion: callback)
    }
    
    public static func coins<CoinList>(_ callback: @escaping Callback<CoinList>) -> Resource<CoinList> {
        return Resource(.coinsList, method: .GET, completion: callback)
    }
    
    public static func marketChart<MarketChart>(currencyId: String, vs: String, days: Int, callback: @escaping Callback<MarketChart>) -> Resource<MarketChart> {
        let params = [URLQueryItem(name: "vs_currency", value: vs),
                      URLQueryItem(name: "days", value: "\(days)")]
        return Resource(.coinsMarketChart, method: .GET, pathParam: currencyId, params: params, completion: callback)
    }
    
    // Coin Gecko API returns candles of diffrent duration based on `days` parameter
    // ```
    //    1 - 2 days: 30 minutes
    //    3 - 30 days: 4 hours
    //    31 and before: 4 days
    // ```
    public static func candles<CandleList>(currencyId: String, vs: String, days: Int, callback: @escaping Callback<CandleList>) -> Resource<CandleList> {
        let params = [URLQueryItem(name: "vs_currency", value: vs),
                      URLQueryItem(name: "days", value: "\(days)")]
        
        let parse: (Data) -> CandleList = { data in
            let decoder = JSONDecoder()
            let arrayData = try? decoder.decode([[Double]].self, from: data)
            return (arrayData ?? []).map { Candle(arrayData: $0) } as! CandleList
        }
                
        return Resource(.ohlc, method: .GET, pathParam: currencyId, params: params, parse: parse, completion: callback)
    }
}
