# multipart-post

## Presentation

HTTP Multipart Post helper that does just that.

## Usage

```lua
local multipart_encode = require("multipart-post")
local ltn12 = require("ltn12")
local https = require("ssl.https")
	
-- Send Telegram message from bot
local request_body = {
	chat_id = CHAT_ID;
	text = "Hello World!";
}


-- Make request
local body, boundary = multipart_encode(request_body)

https.request {
    url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage",
    method = "POST",
    headers = {
        ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
        ["Content-Length"] = #body,
    },
    source = ltn12.source.string(body),
}
```
