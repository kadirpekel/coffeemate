mate = require '../../coffeemate'

mate.get '/', ->
  @resp.end 'Hello World'

mate.listen 3000
