coffeekup = require 'coffeekup'
mate = require '../../lib/coffeemate'


mate.options.renderExt = '.coffeekup'
mate.options.renderDir = 'views'

# bind coffeekup explicitly
mate.options.renderFunc = (tmpl, ctx) ->
  coffeekup.render tmpl, context: ctx
# or use the shortcut sugar below
# mate.coffeekup()

mate.context.highlight = (msg) ->
  "<span style=\"background-color:#ff0\">#{msg}</span>"

mate.get '/', ->
  @foo = 'bar'
  @render 'main'

mate.listen 3000
