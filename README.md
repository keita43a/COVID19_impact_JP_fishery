# COVID19_impact_JP_fishery
The investigation of COVID19 impact on Japanese fishery by publicly available data

## Analysis

See [this page](https://keita43a.github.io/COVID19_impact_JP_fishery/impact_covid19_fish_price.html)


## Data sources 

### Monthly landing at major ports



### Trade statistics 

The data of trade (export and import) of fish products are obttained from Trade Statistics of Japan (財務省貿易統計). The dataset is downloaded from [e-stat.go.jp] (https://www.e-stat.go.jp/stat-search/files?page=1&toukei=00350300&tstat=000001013141&cycle=1&tclass1=000001013195) and cleaned using estatapi. 

貿易の製品のカテゴリは統計品と概況品に分けられ、それぞれ異なるコードで統制されている。統計品のほうが詳細なカテゴリ分けになっており、魚種については学名などで指定されているが、概況品は複数の似た統計品をまとめたカテゴリーわけがなされている。今回の分析においては、まず概況品で大枠をつかみ、必要に応じて統計品のデータを取得して分析する。

概況品では水産物の製品は頭の３桁が007で始まるコードに属している。これに加えて、魚粉・ミールなどを含む01701を加えてデータを取得した。

|概況品コード|単位|概況品目|Articles| 統計品目番号(HS code)|
|----|---|---|---|---|
|007|MT|魚介類及び同調製品|FISH AND FISH PREPARATION|
|00701|MT|　魚介類|FISH||
|0070101|MT|（鮮魚、冷蔵魚及び冷凍魚）|FISH,FRESH,CHILLED,FROZEN|0301～0304|
|00701011|MT|《かつお》 |SKIPJACK AND BONITO|0302.33 , 0303.43 , 0303.89-4 , 0304.87-2|
|00701012|MT|《まぐろ》|ALBACORE AND TUNA|0302.31～0302.32 , 0302.34～0302.39 , 0303.41～0303.42 , 0303.44～0303.49 , 0304.49-1 , 0304.59-1 , 0304.87-1|
|00701013|KG|《たら》|TARA|0302.55 , 0302.59-1 , 0303.67 , 0303.69-1 , 0304.75 , 0304.94-9|
|00701014|KG|《たらのすり身》|SURIMI OF TARA|0304.94-1|
|00701015|KG |《さけ》|SALMON|0302.13～0302.14 , 0303.11～0303.13 , 0304.41 , 0304.81|
|0070103|MT|（甲殼類及び軟体動物）|CRUSTACEA AND MOLLUSCS |0306～0308|
|00701031|MT|かに|CRABS|0306.14 , 0306.33 , 0306.93|
|00705|MT|魚介類の調製品|FISH PREPARATION|1604～1605|
|01701|MT|魚介類の粉、ミール及びペレット|FISH FLOURS, MEAL AND PELLETS|2301.20|
