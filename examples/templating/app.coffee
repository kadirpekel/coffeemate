mate = require '../../lib/coffeemate'

mate.get '/:page?', ->
  @foo = 'bar'        # this is a context variable
  @render 'main.coffeekup'

mate.listen 3000
