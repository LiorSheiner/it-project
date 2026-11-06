# Data Source Proposals

## Proposal 1: Supermarket prices vs. the dollar ("Rockets and Feathers")

What:
Every day we save the prices of all products in two Carrefour stores, both imported and Israeli. We want to know if imported products get more expensive when the dollar goes up, how fast, and if they get cheaper just as fast when it goes down. Economists call this "rockets and feathers": prices go up fast and come down slow. It is usually tested on fuel, and we test it on food.

Two sources:
- Carrefour's daily price files. By Israeli law (the Food Act, 2014), every big chain must publish the price of every product in every store.
- The USD/ILS rate from the Bank of Israel and the Brent oil price from FRED, as context.

URLs:
- File list: https://prices.carrefour.co.il/
- One file: https://prices.carrefour.co.il/20261106/PriceFull7290055700007-001-002-20261106-051001.gz
- Exchange rate: https://edge.boi.gov.il/FusionEdgeServer/sdmx/v2/data/dataflow/BOI.STATISTICS/EXR/1.0/RER_USD_ILS?format=csv&startperiod=2026-10-01
- Oil: https://fred.stlouisfed.org/graph/fredgraph.csv?id=DCOILBRENTEU

Data that is lost if not saved:
The daily price of each product in each store. Every new file replaces the old one, and the chain does not keep old prices. Price comparison sites collect prices too, but we did not find a free archive of the daily files. The exchange rate and the oil price are archived by the Bank of Israel and FRED, so they are only context.

Content:
- Carrefour, per product: code, name, manufacturer, country of origin, size, price, unit price and the time of the last price update.
- Exchange rate and oil: date and value.

Findings we want to check:
- When the dollar goes up, how many days until imported products get more expensive?
- When it goes down, do they get cheaper just as fast?
- Do imported products react differently from Israeli ones (our comparison group)?
- Which product groups (coffee, chocolate, pasta, oil) react the most?

Warning:
- Importers buy stock in advance and some hedge against currency changes, so prices may react slower than one semester. A small or no effect is also a finding.
- The dollar already rose about 3.7% from October 1 to November 6 (3.08 to 3.194 shekels), so we can test the "rocket" side right away. The "feather" side needs the dollar to fall later, which may not happen.
- We group products by their name, which is in Hebrew and not always clear.
- Some products have no clear country of origin. We count them and leave them out.
- Each file has about 5,800 products, so we keep only two stores.

Update frequency: the chain publishes a new full file every morning, and we sample once a day. In our test, dozens of prices changed in the first days of November. The file name includes the publish time (for example 051001), so collect.sh first reads the file list and then downloads the newest file of each store.

Expected size: one store file is about 0.44 MB compressed (5 MB as XML), so two stores a day add up to less than 100 MB for the semester. With startperiod, the Bank of Israel sends only recent days instead of the full history since 1948.

Key or password: not needed. The files are public by law, and robots.txt does not block general clients like curl. The Bank of Israel and FRED do not need a key either.

Data sample (one imported product, store 002, file of 2026-11-06):

```xml
<Item>
  <PriceUpdateTime>2026-07-20T12:52:03.000</PriceUpdateTime>
  <ItemCode>7290119380466</ItemCode>
  <ItemName>נמס קפה קר בטעם פסק</ItemName>
  <ManufactureName>מוקטה אס.פי.</ManufactureName>
  <ManufactureCountry>פולין</ManufactureCountry>
  <UnitQty>גרם</UnitQty>
  <Quantity>200.00</Quantity>
  <ItemPrice>30.90</ItemPrice>
  <UnitOfMeasurePrice>15.45</UnitOfMeasurePrice>
</Item>
```

Exchange rate sample (columns shortened):

```
TIME_PERIOD,OBS_VALUE
2026-11-04,3.157
2026-11-05,3.167
2026-11-06,3.194
```

## Proposal 2: The Polymarket homepage effect

What:
Polymarket is a website where people bet on future events. Its team chooses which events go into the "Featured" list at the top of the homepage, and in what order. Every hour we save this list and how much money is bet on each event. We want to know if an event gets more bets after it enters the list, how fast, and what happens when it leaves.

Two sources:
- Polymarket's public API: the featured list and the trading numbers of each event.
- The Bitcoin price from Coinbase, as context. Users bet with pUSD, a digital dollar backed by USDC, and we guess many of them also follow crypto. Bitcoin shows how much the crypto market moves each day.

URLs:
- Featured events (order in featuredOrder): https://gamma-api.polymarket.com/events?active=true&closed=false&featured=true&limit=100
- Comparison group, top 50 events by 24h volume: https://gamma-api.polymarket.com/events?active=true&closed=false&order=volume24hr&ascending=false&limit=50
- Bitcoin: https://api.exchange.coinbase.com/products/BTC-USD/ticker

Data that is lost if not saved:
The featured list. Trades and volume are on the blockchain and can be rebuilt, but the featured list is chosen by people, and the API shows only the current list. The Wayback Machine has only 1 to 5 homepage snapshots a day, so an hourly history exists only if someone saves it.

Content:
- Polymarket, per event: slug (event name in the URL), title, featured, featuredOrder, creation date, 24h volume, total volume, liquidity, open interest and topic tags.
- Bitcoin: price, bid, ask and 24h volume.

Findings we want to check:
- Does an event's 24h volume go up after it enters the list, compared with events that are not featured? After how many hours?
- Does Polymarket feature events that are already growing, or does the growth come after?
- Is place 1 worth more than place 10? Which topics get the biggest push? Today the list is almost all politics.
- Is the effect smaller on days when Bitcoin moves a lot?

Warning:
- The list may change slowly. It was the same in two samples 10 minutes apart, but it already had events created on November 4 and 5. We will count entries and exits in the first week.
- The carousel on the website can differ a little from featuredOrder, and between users. We use the order from the API.
- The terms of use (the section "Your Responsibilities & Prohibited Conduct") forbid robots and data mining tools on the website, so we do not scrape it. We use only the public API. Polymarket's documentation shows how to read market data with a public client, and our curl requests worked with no key or login. We send two requests an hour, for a non-commercial university project. robots.txt of polymarket.com allows everything.

Update frequency: once an hour. Volume and liquidity change between samples.

Expected size: one full API answer for the featured list is about 3.9 MB, because each event includes all of its markets. That is about 7.8 GB for the semester, so collect.sh keeps only the fields we need with jq before writing to raw/. This is about 47 KB per sample (14 KB compressed), or about 95 MB (30 MB compressed) for 2,000 hourly samples.

Key or password: not needed. Each URL works with one curl command.

Data sample (one featured event, 2026-11-06 12:23 UTC, tags shortened):

```json
{
  "slug": "us-iran-effective-ceasefire-continues-throughptptpt-20261103",
  "title": "US-Iran effective ceasefire continues through...?",
  "featured": true,
  "featuredOrder": 4,
  "createdAt": "2026-11-04T06:07:20.106076Z",
  "volume24hr": 430235.427364,
  "liquidity": 446659.84398,
  "openInterest": 460439.582138,
  "tags": ["Iran", "Trump", "Israel", "Politics", "Geopolitics"]
}
```

Bitcoin sample (same time):

```json
{"ask":"76104.83","bid":"76103.4","volume":"14830.73110145","price":"76104.83","time":"2026-11-06T12:22:25.923108275Z"}
```

## Our ranking

1. Proposal 1 (supermarket prices). The files are public by law, the data changes every day, and the question is close to our daily life.
2. Proposal 2 (Polymarket homepage). It is very easy to collect, and the featured list is lost if nobody saves it. But prediction markets keep a lot of their history, and we do not know yet how often the list changes.
