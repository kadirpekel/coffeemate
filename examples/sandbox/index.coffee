mate = require '../../lib/coffeemate'

# use some of connect middlewares
mate.logger()
mate.static("#{__dirname}/public")

# import extensions
require './extensions'

# import sub applications
mate.use '/base', require './base'
mate.use '/posts', require './posts'
mate.use '/comments', require './comments'

# redirect root
mate.get '/', -> @redirect '/base'
  
# start the engines
mate.listen 3000