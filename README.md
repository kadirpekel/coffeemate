``` coffeescript
###
        (
     (   )
      )_) __(
   .-(   )   )-.
  (   )     (   )
  |`-.._____..-'|
  |             ;--.
  |            (__  \
  |   coffee    | )  )
  |    mate     |/  /
  |            (  /
   `-.._____..-'
  
 the coffee creamer!
###

mate = require 'coffeemate'

mate.get '/hi/:dude', ->
  @resp.end 'Hi ' + @req.params.dude

mate.listen 3000

# please stay tuned. <http://twitter.com/kadirpekel>

```