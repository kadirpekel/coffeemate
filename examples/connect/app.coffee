mate = require '../../coffeemate'

mate.logger()
mate.static(__dirname + '/public')

mate.get '/', ->
  @render 'main'
    
mate.listen 3000
