mate = require '../../lib/coffeemate'

mate.helpers.highlight = (msg) ->
  text "<span style=\"background-color:#ff0\">#{msg}</span>"
    
mate.get '/', ->
  @render 'main.coffeekup'

mate.listen 3000
