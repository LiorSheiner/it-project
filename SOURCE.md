# SOURCE.md: Supermarket prices vs. the dollar

We compare the daily shelf prices of the same products in two supermarkets in Petah Tikva with the same price level: Shufersal Deal and Carrefour Amishav. We want to test if imported products get more expensive when the dollar goes up, how fast, and if they get cheaper just as fast when it goes down.

## 1. Data sources

| | Shufersal (main source) | Carrefour (comparison) | Bank of Israel (the factor we test) |
|---|---|---|---|
| Name | Shufersal price transparency site | Carrefour price transparency site | Representative exchange rates USD/ILS and EUR/ILS |
| URL | https://prices.shufersal.co.il | https://prices.carrefour.co.il | https://edge.boi.gov.il/FusionEdgeServer/sdmx/v2/data/dataflow/BOI.STATISTICS/EXR/1.0/RER_USD_ILS+RER_EUR_ILS?format=csv&startperiod=YYYY-mm-dd (one week before the sampling day, so we do not download the full history) |
| Store | 290, Shufersal Deal Yachin Center, Petah Tikva | 437, Carrefour Amishav, Petah Tikva | (not relevant) |
| Data format | XML compressed with gzip, one PriceFull file per store | XML compressed with gzip, one PriceFull file per store | CSV |
| Key or username | Not needed | Not needed | Not needed |
| License | Public by law (Promotion of Competition in the Food Industry Law, 2014). No other license on the site. | Public by law (same law). No other license on the site. | Public data of the Bank of Israel |
| History on the site | Today's files only. Old files cannot be downloaded. | About 3 months back | Full history |
| Publish time (UTC) | About 01:00. Sometimes a second full file later in the day (19.11 at 10:56). | About 03:10 | Once a business day (Monday to Friday), in the early afternoon Israel time, after the price files. No rate on weekends and holidays. |
| Sampling frequency | Once a day | Once a day | Once a day |

Both stores are in the same city and at the same price level. Shufersal is the source that is lost if we do not save it. We collect Carrefour every day too.

The chains write times in Israel local time (UTC+2 in winter, UTC+3 in summer). We convert every time to UTC.

## 2. What we collect

Every day we download the PriceFull file of each store. This file is a full snapshot of every product in the store at publish time: barcode, name, manufacturer, country of origin, package size, price, unit price and the time of the last price change. Shufersal 290 and Carrefour 437 have about 9,130 products each. About 2,940 barcodes appear in both stores on the same day.

We also save the USD/ILS and EUR/ILS representative rates from the Bank of Israel, one file a day: raw/YYYY-mm-dd/HHMM.csv, with the rates of the last week. This file is not part of the 4 samples above. The bank keeps the full history, so this source is not lost if we miss a day, but it is the factor we test. We keep the euro too, because 23 of the 30 imported products in our basket come from euro countries.

Raw files are saved without any change under `raw/YYYY-mm-dd/HHMM.ext`. For price files, the date and HHMM are the publish time from the original file name, converted to UTC. The two chains publish at different times, so file names do not clash. The chain is identified by `ChainID` inside the file, not by the file name.

| Folder | Shufersal 290 | Carrefour 437 |
|---|---|---|
| raw/2026-11-17 | 0100.xml.gz | 0310.xml.gz |
| raw/2026-11-18 | 0100.xml.gz | 0310.xml.gz |
| raw/2026-11-19 | 1056.xml.gz | 0310.xml.gz |
| raw/2026-11-20 | 0210.xml.gz | 0310.xml.gz |

The four Carrefour files were downloaded on 20.11 from the chain's archive. They are the original files published on each of these days.

Store number check: inside the Carrefour files `StoreID` is 275, not 437. We checked the chain's official Stores file (20.11.2026): store 437 is listed as "קרפור עמישב פ"ת (2750)", and the `StoreID` in Carrefour price files is the first three digits of this internal code. No other Carrefour store uses 275. In Shufersal files `StoreID` is 290, the store number itself.

### The product basket

We save the full files, but the analysis uses a fixed basket of 60 products: 30 imported and 30 Israeli. The full list is in the appendix at the end of this file. The basket was chosen once, on 20.11.2026, and stays the same for the whole semester.

We had two goals: products that will not disappear in the middle of the semester, and a basket that makes economic sense.

Stability. A product can enter the basket only if all of these are true. The number after each rule is how many products were left after it:

| Rule | Products left |
|---|---|
| Same barcode in both stores, in all 4 samples | 2,917 |
| Real barcode (8 digits or more, not an internal chain code) | 2,917 |
| Not sold by weight | 2,912 |
| Same package size and unit in both chains | 1,798 |
| Country of origin known in both chains, and both agree if it is Israeli or imported | 1,675 |
| In the Carrefour store file on every day of its archive (21.08 to 20.11, 92 files) | 1,471 |
| Sold at least once in the last 14 days in both stores (`LastSaleDateTime`) | 1,098 |

The archive rule is the strongest test we have: 204 products that were in the 4 samples had disappeared from the Carrefour file on at least one day in the last 3 months. Shufersal has no archive, so for Shufersal we only have the 4 samples and the last sale date. The files have no sales quantities, so we cannot choose by how much a product sells. A recent sale only shows that the product is active on the shelf.

Economic logic. From the 1,098 stable products we chose by hand:
- Only food and drinks, in 10 everyday categories: coffee, chocolate and sweets, biscuits and wafers, breakfast cereal, pasta, rice and grains, salty snacks, canned food, sauces, spreads, and tea.
- In every category 3 imported and 3 Israeli products, so each imported product is compared with Israeli products of the same kind. Where possible we chose direct pairs, for example Heinz ketchup and Osem ketchup, Tilda and Sugat basmati rice, StarKist and Filtuna tuna, Nutella and Hashachar chocolate spread.
- Well known brands.

We left out:
- Products under government price control (milk, cottage cheese, white and hard cheese, cream, butter, eggs, bread, salt) and all other dairy products. Their price is set or strongly affected by the state, not by the market.
- Alcohol and energy drinks, because of special taxes.
- Meat, fish and frozen food, which are often sold by weight or change a lot between seasons.
- Non-food products (cleaning, toiletries).

One thing to keep in mind: many Israeli products also use imported raw materials (cocoa, coffee beans, wheat, rice), so the Israeli group is not free of the dollar. It is less exposed, because only part of its cost is in dollars, while an imported product is bought abroad as a finished product.

If a basket product disappears from a store, its rows for those days are missing. We do not fill them in and we do not replace the product.

## 3. Schema of dataset.csv

One row = one basket product, in one store, on one day. Full day: 60 products in 2 stores = 120 rows.

| Column | Content | Units / format |
|---|---|---|
| `date` | Date of the raw folder (publish date) | YYYY-mm-dd, UTC |
| `chain` | Chain name | `shufersal` / `carrefour` |
| `store_id` | Store number on the chain's site | integer (290 / 437) |
| `barcode` | Product barcode | text, 8 to 13 digits |
| `item_name` | Product name | text (Hebrew) |
| `category` | Basket category (coffee, chocolate, ...) | text, one of the 10 categories in section 2 |
| `country` | Country of origin | 2-letter ISO 3166 code (IL, IT, CN...), empty if unknown |
| `is_imported` | Is the product imported | 1 = imported, 0 = Israeli, empty if unknown |
| `quantity` | Package size | number |
| `unit` | Unit of the package size | `g` / `ml` / `kg` / `l` / `unit` |
| `price_ils` | Shelf price, without promotions | ILS |
| `price_update_utc` | Last time the chain changed the price | YYYY-mm-ddTHH:MM:SSZ, UTC |
| `usd_ils` | The last USD/ILS representative rate published before the price file of this row | ILS per 1 USD |
| `eur_ils` | The last EUR/ILS representative rate published before the price file of this row | ILS per 1 EUR |

## 4. Why these columns

We keep:
- `barcode`: the only safe way to match the same product in both chains, because names are written differently.
- `category`: lets us compare imported and Israeli products of the same kind.
- `country` and `is_imported`: they split the basket into imported (exposed to the dollar) and Israeli (our comparison group).
- `price_ils`: the value we measure.
- `price_update_utc`: shows exactly when a price changed, even if we missed a day of sampling.
- `quantity` and `unit`: the barcode stays the same if the producer makes the package smaller, so these columns show if the price changed or the package changed.
- `usd_ils` and `eur_ils`: the factor we test. The rate is published in the afternoon and the price files in the morning, so a rate from the same date was not known yet when the prices were set. That is why each row gets the last rate published before its price file (for a Monday price file, the rate of the Friday before). This is the rate that was really in force. We do not estimate missing rates.
- Both currencies: most imported products in the basket come from euro countries, but importers may also pay in dollars. Keeping both lets the data show which rate the prices follow.

We do not keep (all of them stay in `raw/`, so a column can be added later):
- `UnitOfMeasurePrice` and `UnitOfMeasure`: we compare the same barcode, so the package is the same and the shelf price is enough. `UnitOfMeasure` is also written in 12 different ways in Carrefour.
- `ManufactureName`: empty or "," in about a quarter of Carrefour products, and the barcode already identifies the product.
- `ManufactureItemDescription`: the same as `ItemName` in almost all products.
- `LastSaleDateTime`: used once to choose the basket (see section 2), not needed for the price question.
- `bIsWeighted`: no basket product is sold by weight, so it is always 0.
- `ItemType`, `AllowDiscount`: technical flags that are almost always 1.
- `ItemStatus`: always empty.
- `QtyInPackage`: "לא ידוע" for every Carrefour product.
- `ChainID`, `SubChainID`, `StoreID`, `BikoretNo`: file header fields. `ChainID` is used to fill `chain` and `store_id`, and `StoreID` only to check the store.
- Promotions (Promo and PromoFull files): we study the regular shelf price only.
- Products that are not in the basket (see "The product basket" above).

What we learned from the first 4 samples: few prices change each day (0 to 8 per store), so most of the signal will come from changes over weeks. Products also enter and leave the files (9 to 36 a day), which is why the basket only has products that were in both stores in all 4 samples.

## 5. Translation table: source fields to schema

| Source field | Schema column | Change |
|---|---|---|
| (raw folder name) | `date` | none |
| `ChainID` (7290027600007 / 7290055700007) | `chain` | 7290027600007 to `shufersal`, 7290055700007 to `carrefour` |
| `ChainID` | `store_id` | 7290027600007 to 290, 7290055700007 to 437 (one store per chain). Checked against `StoreID`: 290 for Shufersal, 275 for Carrefour. |
| `ItemCode` | `barcode` | none |
| `ItemName` | `item_name` | trim spaces |
| (our basket list, by barcode) | `category` | none |
| `ManufactureCountry` | `country` | Shufersal already uses ISO codes. Carrefour uses Hebrew names (ישראל, איטליה, also USA) and we convert them with a fixed table of 74 names. "לא ידוע" or empty to empty. |
| `ManufactureCountry` | `is_imported` | IL to 0, any other country to 1, unknown to empty |
| `Quantity` | `quantity` | none |
| `UnitQty` | `unit` | גרם to g, מיליליטר to ml, קילוגרם / קילוגרמים to kg, ליטר / ליטרים to l, יחידות to unit, מטרים to m, לא ידוע to empty |
| `ItemPrice` | `price_ils` | none |
| `PriceUpdateTime` | `price_update_utc` | remove milliseconds (Carrefour), convert Israel time to UTC |
| Bank of Israel `OBS_VALUE` of `RER_USD_ILS` | `usd_ils` | take the last `TIME_PERIOD` before the date of the price file |
| Bank of Israel `OBS_VALUE` of `RER_EUR_ILS` | `eur_ils` | take the last `TIME_PERIOD` before the date of the price file |

## 6. Expected size after one semester

We assume about 100 days of sampling (from 17.11.2026 to the end of February 2027).

raw/ folder: a Shufersal file is about 460 KB and a Carrefour file about 690 KB, about 1.15 MB a day. The Bank of Israel file adds a few KB. After 100 days: about 115 MB.

dataset.csv: 120 rows a day (60 basket products in 2 stores), about 140 bytes a row, so about 17 KB a day. After 100 days: about 12,000 rows and about 1.7 MB.

Together this is about 117 MB, under the 500 MB limit of the course server. Almost all of it is raw/, because we keep the full files and not only the basket.

## Appendix: the basket

Product names are as written by Shufersal. Carrefour writes some of them differently, but the barcode is the same.

| # | Category | Group | Barcode | Product (Shufersal name) | Country | Size |
|---|---|---|---|---|---|---|
| 1 | Coffee | imported | 8711000601587 | קפה קרונונג 190גר ג'קובס | RU | 190 g |
| 2 | Coffee | imported | 4607001774556 | גייקובס קפה נמס גולד190 | DE | 190 g |
| 3 | Coffee | imported | 7290000072753 | קפה נמס טסטרס צ'ויס200ג | FR | 200 g |
| 4 | Coffee | local | 7290000176420 | קפה נמס 200 גרם עלית | IL | 200 g |
| 5 | Coffee | local | 7290000419107 | קפה שחור לנדוור 100 גרם | IL | 100 g |
| 6 | Coffee | local | 7290002771388 | קפה שחור+הל 100ג אל נחלה | IL | 100 g |
| 7 | Chocolate and sweets | imported | 7290018893807 | שוק.מריר60% 3*100ג צוקטה | ES | 300 g |
| 8 | Chocolate and sweets | imported | 87108651 | מנטוס מנטה 4יח37.5Xגרם | NL | 150 g |
| 9 | Chocolate and sweets | imported | 25675120068 | חמצוצים בטעם קולה 100גרם | NL | 100 g |
| 10 | Chocolate and sweets | local | 7290000178134 | שוקולד פרה מריר 4*100גרם | IL | 400 g |
| 11 | Chocolate and sweets | local | 7290112914705 | שוק.מריר 70% מקס ברנר90ג | IL | 90 g |
| 12 | Chocolate and sweets | local | 72917329 | חטיף שוקולד אגוזי 45 גרם | IL | 45 g |
| 13 | Biscuits and wafers | imported | 7622010001858 | עוג.אוראו קרם וניל 176ג | CZ | 176 g |
| 14 | Biscuits and wafers | imported | 7290018893036 | עוגיות סנדוויץ176ג צוקטה | ES | 176 g |
| 15 | Biscuits and wafers | imported | 7290000080758 | טוסטעים פת קלויה 100 גרם | NL | 100 g |
| 16 | Biscuits and wafers | local | 7290000061245 | עוג.שוקוצ'יפס+שוקו220אסם | IL | 220 g |
| 17 | Biscuits and wafers | local | 7290107951111 | בפלות בטעם לימון 200 גרם | IL | 200 g |
| 18 | Biscuits and wafers | local | 7290000313184 | עוג.גן חיות וניל 250 גרם | IL | 250 g |
| 19 | Breakfast cereal | imported | 8445291426320 | דגני בוקר פיטנס קלאסי375 | FR | 375 g |
| 20 | Breakfast cereal | imported | 7290014471429 | מוזלי פירות יבשים 850ג | MK | 850 g |
| 21 | Breakfast cereal | imported | 7290116538662 | ברנפלקס דגני בוקר452 גרם | IT | 452 g |
| 22 | Breakfast cereal | local | 7290112494351 | קורנפלקס אלופים בדץ 850ג | IL | 850 g |
| 23 | Breakfast cereal | local | 7290116537351 | כריות נוגט 686 גרם תלמה | IL | 686 g |
| 24 | Breakfast cereal | local | 7290109358765 | קראנץ רולס 450 גרם | IL | 450 g |
| 25 | Pasta, rice and grains | imported | 8076802085738 | פנה ריגטה מס73 500 גרם | IT | 500 g |
| 26 | Pasta, rice and grains | imported | 7290000060880 | פסטה ספגטי מס 8 אסם 500ג | IT | 500 g |
| 27 | Pasta, rice and grains | imported | 5011157630281 | אורז בסמטי טילדה 1 ק"ג | IN | 1 kg |
| 28 | Pasta, rice and grains | local | 7290003643004 | אורז בסמטי קלאסי1ק סוגת | IL | 1 kg |
| 29 | Pasta, rice and grains | local | 7290000060200 | פתיתים אפויים קוסקוס500ג | IL | 500 g |
| 30 | Pasta, rice and grains | local | 7290100702260 | קוסקוס דק 350ג סוגת | IL | 350 g |
| 31 | Salty snacks | imported | 7290119373277 | חטיף טבעות בטעם בצל 45 ג | GR | 45 g |
| 32 | Salty snacks | imported | 7290118422501 | ציפס ברביקיו 32*45ג | ES | 45 g |
| 33 | Salty snacks | imported | 5701932026964 | הוטפופ טעם טבעי6*100ג | US | 600 g |
| 34 | Salty snacks | local | 7290000066141 | ביסלי גריל 70 גרם | IL | 70 g |
| 35 | Salty snacks | local | 7290000178707 | תפוציפס בטעם טבעי 50 גר | IL | 50 g |
| 36 | Salty snacks | local | 7290112495112 | חטיף נשנושים זעתר 260 גר | IL | 260 g |
| 37 | Canned food | imported | 7290005287206 | טונה סטארקיסט בשמן4*160ג | VN | 640 g |
| 38 | Canned food | imported | 8005110002243 | תרכיז עגבניות 185 גרם | IT | 185 g |
| 39 | Canned food | imported | 7290100704950 | שימורי שעועית אדומה 400 | IT | 400 g |
| 40 | Canned food | local | 7290010066513 | טונה בשמן צמחי פילטונה4 | IL | 632 g |
| 41 | Canned food | local | 7290018359495 | תירס מהשדה ללת"ס 550 גרם | IL | 550 g |
| 42 | Canned food | local | 7290113193406 | טבעות קוקטייל זיתים 560ג | IL | 560 g |
| 43 | Sauces | imported | 8715700124964 | קטשופ מופחת סוכר ומלח435 | NL | 435 g |
| 44 | Sauces | imported | 7290114600941 | מיונז לחיץ 435ג מאסטרשף | NL | 435 g |
| 45 | Sauces | imported | 8076809513395 | רוטב פומודורו ברילה 400ג | IT | 400 g |
| 46 | Sauces | local | 7290000072623 | קטשופ אסם בקבוק 750גר | IL | 750 g |
| 47 | Sauces | local | 7290000111186 | מיונז אמיתי תלמה 500 גרם | IL | 500 g |
| 48 | Sauces | local | 7290000209722 | רוטב עגב פריכוז יכין580ג | IL | 580 g |
| 49 | Spreads | imported | 8000500426494 | נוטלה על בסיס צמחי 350 ג | IT | 350 g |
| 50 | Spreads | imported | 5014271400426 | מעדן תות שדה 284 גרם | FR | 284 g |
| 51 | Spreads | imported | 7290113197176 | חמאת בוטנים טבעי+שברי510 | IN | 510 g |
| 52 | Spreads | local | 7290000416045 | ממרח בטעם שוקולד השחר1קג | IL | 1 kg |
| 53 | Spreads | local | 7290001216040 | טחינה גולמית אל ארז 500ג | IL | 500 g |
| 54 | Spreads | local | 7290119382873 | קונפיטורה אוכמנ.כחול340ג | IL | 340 g |
| 55 | Tea | imported | 4009300053163 | חליטת ורד בר היביסקוס20ש | DE | 60 g |
| 56 | Tea | imported | 4009300525684 | חליטת לימון גינגר20שק | DE | 35 g |
| 57 | Tea | imported | 7290002360285 | חליטת קמומיל 20 שק*1.5ג | DE | 30 g |
| 58 | Tea | local | 7290000345284 | תה קלאסי ויסוצק 100*1.5ג | IL | 150 g |
| 59 | Tea | local | 7290000345307 | תה ארל גריי 50 שק*1.5גרם | IL | 75 g |
| 60 | Tea | local | 7290001491096 | תה ירוק לימונ+לואיזה50שק | IL | 75 g |
