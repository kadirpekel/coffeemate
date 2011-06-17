Coffeemate!
===========
```
   )
   (
 C[_] coffeemate, the coffee creamer!
```
coffeemate is a web framework built on top of connect and specialized for writing web apps comfortably in coffeescript.
It uses eco template engine by default for fullfill coffeescript experience.


What is it look like?
---------------------

``` coffeescript
# app.coffee

# Require it
mate = require 'coffeemate'

# Connect it
mate.logger()
mate.static("#{__dirname}/public")

# Extend it
mate.context.highlight = (color, txt) ->
  "<span style=\"background-color:#{color}\">#{txt}</span>"

# Route it
mate
  .get '/greet/:name', ->
    # this is context variable
    @greet_msg = "Hello, #{@req.params.name}"
    @resp.render 'home.eco'

# Listen it
mate.listen 3000
```

``` html
<!-- main.eco -->

<h1>Welcome to Coffeemate</h1>
<div><%- @highlight '#f00', @greet_msg %></div>
<div><%- @include 'nested.eco' %></div>
```

``` html
<!-- nested.eco -->

<h2>I'm a partial template</h2>
<div><%- @highlight '#ff0', @greet_msg %></div>
```

Hmmm, What to expect more?

Install
-------

```
$ npm install coffeemate
```

Demos & Examples
----------------

See plenty of examples

<https://github.com/coffeemate/coffeemate/tree/master/examples>

Also wanna see something real and cool? Check coffeegrind, the boilerplate lets you give a great start.

<https://github.com/twilson63/coffeegrind>

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
