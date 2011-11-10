mate = require '../../coffeemate'

mate.options.renderDir = 'templates'
mate.options.renderExt = '.html'

# use some of connect middlewares
mate.logger()
mate.static("#{__dirname}/public")
