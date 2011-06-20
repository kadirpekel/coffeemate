coffeekup = require 'coffeekup'
mate = require '../../lib/coffeemate'


mate.options.renderExt = '.coffeekup'
mate.options.renderDir = 'views'

# Bind coffeekup with an helper

mate.coffeekup highlight: (color, msg) ->
  text "<span style=\"background-color:#{color}\">#{msg}</span>"

mate.get '/', ->
  @foo = 'bar'
  @render 'main'

mate.listen 3000
