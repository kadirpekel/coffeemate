mate = require '../../lib/coffeemate'

mate.context.highlight = (msg) ->
  "<span style=\"background-color:#ff0\">#{msg}</span>"
    
mate.get '/', ->
  @render 'main.eco'

mate.listen 3000
