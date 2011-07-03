mate = require '../../lib/coffeemate'

mate.get '/', ->
  @foo = 'bar'
  @render 'main'

mate.listen 3000
