mate = require '../../lib/coffeemate'

mate.context.view = (viewname, layout) ->
  viewpath = @container.route.slice(1)
  @view = "#{viewpath}/views/#{viewname}.eco"
  @render if layout then "#{viewpath}/views/#{layout}.eco" else  "base/views/layout.eco"
