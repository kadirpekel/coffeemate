mate = require '../../lib/coffeemate'

mate.context.send_xml = (msg) ->
  @resp.setHeader 'Content-Type', 'text/xml'
  @resp.end "<node>#{msg}</node>"
  
mate.get '/', ->
  @send_xml 'Hello World'

mate.listen 3000
