# apb-shuttle-line

#### 航警局車表
網址位置：[http://apb-shuttle.info](http://apb-shuttle.info)

API Doc: [https://apb-shuttle.info/doc/api](https://apb-shuttle.info/doc/api)

---
### 介紹

本專案使用 Sinatra 開發

功能包含：

* [apb_shuttle_api](https://github.com/jiunjiun/apb_shuttle_api)
* [Open Data](https://apb-shuttle.info/doc/api)


---
### 基本設定

設定Heroku

```
git push heroku master
```

設定Line SECRET and TOKEN to Heroku

從這邊[https://developers.line.me/](https://developers.line.me/)後台找到 `Channel Secret`, `Channel Access Token` 加入Heroku

```
heroku config:set LINE_CHANNEL_SECRET=<Channel Secret>
heroku config:set LINE_CHANNEL_TOKEN=<Channel Access Token>
```

---
### 感謝

* 感謝 Collie 圖文訊息選單設計
* 感謝 科科安 再一次拯救世界


## Copyright / License
* Copyright (c) 2016 jiunjiun (quietmes At gmail.com)
* Licensed under [MIT](https://github.com/jiunjiun/apb-shuttle-line/blob/master/LICENSE) licenses.
