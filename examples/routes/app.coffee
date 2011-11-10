mate = require '../../coffeemate'

mate.get '/', ->
  @resp.end 'Hello World'
  
mate.get '/greet/:name', ->
  @resp.end 'Hello ' + @req.params.name

mate.get '/greet_if/:name?', ->
  @resp.end 'Hello ' + (@req.params.name or 'World')

mate.listen 3000
