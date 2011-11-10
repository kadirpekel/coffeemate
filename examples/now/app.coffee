mate = require '../../coffeemate.coffee'

mate.options.renderLayout = no

mate.get '/', ->
  @render 'main'

mate.now.greet = -> 
  console.log "Hello World"

mate.listen 3000
