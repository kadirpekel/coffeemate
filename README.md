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

Route Chaining
------
``` coffeescript
mate = require 'coffeemate'

mate

.get '/this', ->
 	@resp.end 'This'
  
.post '/is', ->
 	@resp.end 'is'

.put '/chaining', ->
  @resp.end 'chaining'
	
.del '/example', ->
  @resp.end 'example'
	
.listen 3000
```

Middleware
----------
``` coffeescript
mate = require 'coffeemate'

mate.logger()
mate.static(__dirname + '/public')

mate.get '/', ->
  @render 'main.eco'
    
mate.listen 3000
```

Templating
----------
``` coffeescript
mate = require 'coffeemate'

mate.get '/:page?', ->
	# this is a context variable
  @foo = 'bar'
  @render 'main.eco'

mate.listen 3000
```

``` html
# main.eco

<h1>this is main template for path: <%= @req.url %></h1>
<div>This is foo: <%= @foo %></div>
<div><%- @include 'nested.eco' %></div>
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

Helpers (Extensions)
--------------------
``` coffeescript
mate = require 'coffeemate'

mate.context.highlight = (msg) ->
	"<span style=\"background-color:#ff0\">#{msg}</span>"
    
mate.get '/', ->
  @render 'main.eco'

mate.listen 3000
```

``` html
# main.eco

<h1>Demonstrating helpers</h1>
<div>
  <%- @highlight "This is a highlighted text" %>
</div>
```

Layouts
-------
``` coffeescript
mate = require 'coffeemate'

# build your own layout structure using extensions
mate.context.custom_render = (template_name) ->
  @content = template_name
  @render 'layout.eco'

mate.get '/', ->
  @foo = 'bar'
  @custom_render 'main.eco'

mate.listen 3000
```

``` html
# layout.eco

<html>
  <head></head>
  <body>
    <div>This is HEADER</div>
    <div><%- @include @content %></div>
    <div>This is FOOTER</div>
  </body>
</html>
```

``` coffeescript
# main.eco

<blockquote>
  This is main content
  <p>Also this is foo: <%= @foo %></p>
</blockquote>
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
