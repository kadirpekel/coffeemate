mate = require '../../coffeemate'

mate.context.highlight = (msg) ->
  "<span style=\"background-color:#ff0\">#{msg}</span>"
    
mate.get '/', ->
  @render 'main'

mate.listen 3000
