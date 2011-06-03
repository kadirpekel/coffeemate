mate = require '../../lib/coffeemate'

mate.get '/:page?', ->
  @foo = 'bar'
  @render 'home.coffeekup'

mate.listen 3000
