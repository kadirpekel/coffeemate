mate = require '../../lib/coffeemate'

# build your own layout structure
mate.context.custom_render = (template_name) ->
  @content = template_name
  @render 'layout.coffeekup'

mate.get '/', ->
  @foo = 'bar'
  @custom_render 'main.coffeekup'

mate.listen 3000
