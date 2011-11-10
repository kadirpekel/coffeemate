mate = require '../../coffeemate'

mate.get '/', ->
  @foo = 'bar'
  @render 'main'

mate.listen 3000
