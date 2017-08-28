# Description
#   A hubot script that suggests random food from online food ordering company yemeksepeti.com
#
# Configuration:
#   HUBOT_YEMEKSEPETI_CITY
#   HUBOT_YEMEKSEPETI_AREA
#
# Commands:
#   hubot acıktık
#   hubot ne yesek
#   hubot sen bize naap biliyo musun
#   hubot little little in to the middle
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Mehmet Ali Aydın <maaydin@gmail.com>

osmosis = require('osmosis')

salutations = [
  "@% ne vereyim abime",
  "Bana bırakıyor musun @% abi",
]
suggestions = [
   "@% bak <{{link}}|{{name}}> diyorum, başka da bir şey demiyorum.",
   "@% senin de burnuna <{{link}}|{{name}}> kokusu gelmiyor mu?",
   "@% şimdi bir <{{link}}|{{name}}> ne iyi gider!"
]

city = process.env.HUBOT_YEMEKSEPETI_CITY ? "istanbul"
area = process.env.HUBOT_YEMEKSEPETI_AREA ? "maslak-itu-kampusu"

yemeksepeti = (msg) ->
   restaurants = []
   products = []
   osmosis.get('https://www.yemeksepeti.com/'+city+'/'+area)
      .find('.ys-reslist .ys-item .head')
      .set({'href':'@href'})
      .data((restaurant) ->
         restaurants.push restaurant
      ).done ->
         restaurant = restaurants[Math.floor(Math.random() * restaurants.length)]
         if restaurant?
            osmosis.get('https://www.yemeksepeti.com' + restaurant.href)
               .find('.favFoods,.menu_1,.menu_2,.menu_3 .productName')
               .set({
                     'name' : 'a'
                     'altname' : 'i@data-productname'
                     'image':'i@data-imagepath'
                  })
               .data((product) ->
                  products.push product
               ).done ->
                  product = products[Math.floor(Math.random() * products.length)]
                  if product?
                     suggestion = msg.random suggestions
                     if product.name != ""
                        suggestion = suggestion.replace "%", msg.message.user.name
                        suggestion = suggestion.replace "{{name}}", product.name
                        suggestion = suggestion.replace "{{link}}", 'https://www.yemeksepeti.com' + restaurant.href
                        msg.send suggestion
                     else
                        suggestion = suggestion.replace "%", msg.message.user.name
                        suggestion = suggestion.replace "{{name}}", product.altname
                        suggestion = suggestion.replace "{{link}}", 'https://www.yemeksepeti.com' + restaurant.href
                        suggestion = suggestion + '<http:' + product.image + '|..>'
                        msg.send suggestion
                  else
                     msg.send "@" + msg.message.user.name + " şu an bir tavsiyede bulunamıyorum"
         else
            msg.send "@" + msg.message.user.name + " şu an bir tavsiyede bulunamıyorum, HUBOT_YEMEKSEPETI_CITY ve HUBOT_YEMEKSEPETI_AREA değişkenlerini tanımlamış mıydın?"

module.exports = (robot) ->
   robot.respond /.*(yeme|yese|ac.kt.|aç..|zil .al.yor|ne ver.|ne yap|naap|menu|menü|little).*/i, (msg) ->
      salutation = msg.random salutations
      msg.send salutation.replace "%", msg.message.user.name
      yemeksepeti msg
