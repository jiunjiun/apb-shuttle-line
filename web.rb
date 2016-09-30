require 'sinatra'
require 'sinatra/logger'
require 'line/bot'
require 'apb_shuttle_api'

post '/callback' do
  body = request.body.read
  logger.info { " -- body: #{body}" }

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    logger.info { " -- event: #{event}" }
    case event
    when Line::Bot::Event::Message
      response = nil
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = filter_message(event.message['text'])
        if message != {}
          response = client.reply_message(event['replyToken'], message)
          logger.info { " -- response: #{response.body}" }
        end
      end
    end
  }

  "OK"
end

private
def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token  = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def navigation
  message = {
    "type": "template",
    "altText": "this is a buttons template",
    "template": {
      "type": "buttons",
      "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
      "title": "Menu",
      "text": "Please select",
      "actions": [
          {
            "type": "postback",
            "label": "Buy",
            "data": "action=buy&itemid=123"
          },
          {
            "type": "postback",
            "label": "Add to cart",
            "data": "action=add&itemid=123"
          },
          {
            "type": "uri",
            "label": "View detail",
            "uri": "http://example.com/page/123"
          }
      ]
    }
  }
end

def filter_message(text)
  msg = ''
  case text
  when '最新班次'
    now = ApbShuttleApi.now
    msg = bus_card(now['bus'])

    message = {
      type: 'text',
      text: msg
    }
  when '下一班'
    next_1 = ApbShuttleApi.next(1)
    msg = bus_card(next_1['bus'])

    message = {
      type: 'text',
      text: msg
    }
  when '下兩班'
    next_2 = ApbShuttleApi.next(2)
    msg = bus_card(next_2['bus'])

    message = {
      type: 'text',
      text: msg
    }
  when '下三班'
    next_3 = ApbShuttleApi.next(3)
    msg = bus_card(next_3['bus'])

    message = {
      type: 'text',
      text: msg
    }
  when '下四班'
    next_4 = ApbShuttleApi.next(4)
    msg = bus_card(next_4['bus'])

    message = {
      type: 'text',
      text: msg
    }
  when '警備資訊'
    info = ApbShuttleApi.info
    originalContentUrl = info['info']['apb']['imgs_url']['original'].gsub('http', 'https')
    previewImageUrl = info['info']['apb']['imgs_url']['mobile'].gsub('http', 'https')

    message = [{
        type: "image",
        originalContentUrl: originalContentUrl,
        previewImageUrl: previewImageUrl
      }, {
        type: 'text',
        text: "若看不到，請點: #{info['info']['apb']['imgs_url']['original']}"
      }
    ]
  when '亞通資訊'
    info = ApbShuttleApi.info
    ref_img = info['info']['orange']['ref_img']
    ref_link = info['info']['orange']['ref_link']

    ref_img_msg = "圖片連結: #{ref_img}"
    ref_link_msg = "參考連結: #{ref_link}"
    messages = [{
        type: 'text',
        text: ref_img_msg
      }, {
        type: 'text',
        text: ref_link_msg
      }
    ]
  when '科科安'
    message = [{
        type: 'text',
        text: "科科安，好棒棒，快笑兩聲來聽聽"
      },
      {
        type: 'sticker',
        packageId: '1',
        stickerId: '106',
      }
    ]
  else
    message = [{
        type: 'text',
        text: "點擊「查看更多資訊」，或是輸入\n「最新班次」、「下一班」、「警備資訊」、「亞通資訊」\n就可以使用了哦"
      },
      {
        type: 'sticker',
        packageId: '2',
        stickerId: '144',
      }
    ]
  end
end

def bus_card(bus)
  kind    = bus_kind(bus['kind'])
  special = bus['special'] ? '[加班車]' : ''
  note    = bus['note']
  depart  = bus['depart']
  depart_note = bus['kind'] == 1 ? '✱局本部假日不開' : ''

  msg = "#{kind} - #{note}\n#{depart} #{special}"
  msg += "#{msg}\n#{depart_note}" if depart_note
  msg
end

def bus_kind(kind)
  case kind
  when 1
    '局本部'
  when 2
    '保安隊'
  when 3
    '安檢隊'
  when 4
    '亞通客運'
  end
end
