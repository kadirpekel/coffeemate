mate = require '../../lib/coffeemate.coffee'

mate.get '/', ->
  @render 'main.eco'

mate.io.sockets.on 'connection', (socket, i=0) ->
  setInterval (-> socket.emit 'news', "Breaking news #{i++}"), 500
  
mate.listen 3000
