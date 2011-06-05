Coffeemate!
===========
```
     )
     (
   C[_] coffeemate, the coffee creamer!
```
coffeemate is a web framework built on top of connect and specialized for writing web apps comfortably in coffeescript.

First Glance
------------
``` coffeescript
mate = require 'coffeemate'

mate.get '/', ->
  @resp.end 'Hello World'

mate.listen 3000
```

Router
------
``` coffeescript
mate = require 'coffeemate'

mate.get '/', ->
  @resp.end 'Hello World'
  
mate.get '/greet/:name', ->
  @resp.end 'Hello ' + @req.params.name

mate.get '/greetif/:name?', ->
  @resp.end 'Hello ' + (@req.params.name or 'World')

mate.listen 3000
```

Middleware
----------
``` coffeescript
mate = require 'coffeemate'

mate.logger()
mate.static(__dirname + '/public')

mate.get '/', ->
  @render 'main.coffeekup'
    
mate.listen 3000
```

Templating
----------
``` coffeescript
mate = require 'coffeemate'

mate.get '/:page?', ->
	# this is a context variable
  @foo = 'bar'
  @render 'main.coffeekup'

mate.listen 3000
```

```
# main.coffeekup

h1 "this is main template for path: #{@req.url}"

div "this is foo: ", ->
  span @foo

div ->
  include 'nested.coffeekup'
```

Helpers
-------
``` coffeescript
mate = require '../../lib/coffeemate'

mate.helpers.highlight = (msg) ->
  text "<span style=\"background-color:#ff0\">#{msg}</span>"
    
mate.get '/', ->
  @render 'main.coffeekup'

mate.listen 3000
```

```
# main.coffeekup

h1 "Demonstrating helpers"

div ->
  highlight "This is a highlighted text"
```

Disclaimer
----------
coffeemate is currently in early stages, please stay tuned! <http://twitter.com/kadirpekel>