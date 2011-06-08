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
mate = require 'coffeemate'

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

Extensions
----------
``` coffeescript
mate = require 'coffeemate'

# simply extend the coffeemate context
mate.context.send_xml = (msg) ->
  @resp.setHeader 'Content-Type', 'text/xml'
  @resp.end "<node>#{msg}</node>"

# use the extension
mate.get '/', ->
  @send_xml 'Hello World'

mate.listen 3000
```

Layouts
-------
``` coffeescript
mate = require 'coffeemate'

# build your own layout structure using extensions
mate.context.custom_render = (template_name) ->
  @content = template_name
  @render 'layout.coffeekup'

mate.get '/', ->
  @foo = 'bar'
  @custom_render 'main.coffeekup'

mate.listen 3000
```

``` coffeescript
# layout.coffeekup

html ->
  head ->
  body ->
    div "This is HEADER"
    div ->
      include @content
    div "This is FOOTER"
```

``` coffeescript
# main.coffeekup

blockquote "This is main content", ->
  p "Also this is foo: ", ->
    span "#{@foo}"
```

Disclaimer
----------
coffeemate is currently in early stages, please stay tuned! <http://twitter.com/kadirpekel>

Licence
-------
Copyright (c) 2011 Kadir Pekel.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
