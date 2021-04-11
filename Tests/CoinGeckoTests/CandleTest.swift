import XCTest
@testable import CoinGecko

final class CandleTests: XCTestCase {

    private let client = CoinGeckoClient()

    func testCandles() {
        let exp = XCTestExpectation()
        let id = "bitcoin"
        let vs = "usd"
        let candles = Resources.candles(currencyId: id, vs: vs, days: 180) { (result: Result<CandleList, CoinGeckoError>) in
            switch result {
            case let .success(candleList):
                XCTAssertTrue(candleList.count > 44 && candleList.count < 49,
                              "Unexpected candle count")
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            exp.fulfill()
        }
        client.load(candles)
        wait(for: [exp], timeout: 10.0)
    }
}
