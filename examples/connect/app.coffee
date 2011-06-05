mate = require '../../lib/coffeemate'

mate.logger()
mate.static(__dirname + '/public')

mate.get '/', ->
  @render 'main.coffeekup'
    
mate.listen 3000
