mate = require '../../coffeemate'

mate.cookieParser()
mate.bodyParser()

mate.context.authenticate = ->
  authenticated = @req.cookies.authenticated is 'yes'
  @redirect '/login' unless authenticated
  return authenticated

mate.get '/', ->
  @render 'main.eco' if @authenticate()

mate.get '/login', ->
  @render 'login.eco'

mate.post '/login', ->
  authenticated = @req.body.user is 'coffee' and @req.body.pass is 'mate'
  if authenticated
    @resp.setHeader("Set-Cookie", ["authenticated=yes"])
    @redirect '/'
  else
    @redirect '/login'

mate.listen 3000
