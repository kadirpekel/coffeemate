mate = require '../../lib/coffeemate'

mate.get '/:page?', ->
  # this is a context variable
  @foo = 'bar'
  
  @render 'main.coffeekup'

mate.listen 3000
