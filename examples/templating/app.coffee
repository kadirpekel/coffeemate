mate = require '../../coffeemate'

mate.get '/:page?', ->
  @foo = 'bar'        # this is a context variable
  @render 'main'

mate.listen 3000
