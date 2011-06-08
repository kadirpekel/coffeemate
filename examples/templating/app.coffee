mate = require '../../lib/coffeemate'

mate.get '/:page?', ->
  @foo = 'bar'        # this is a context variable
  @render 'main.eco'

mate.listen 3000
