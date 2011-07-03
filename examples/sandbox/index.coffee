mate = require '../../lib/coffeemate'

# import configuration
require './settings'

# import sub applications
mate.sub '/base', -> require './base'
mate.sub '/posts', -> require './posts'
mate.sub '/comments', -> require './comments'

# redirect root
mate.get '/', -> @redirect '/base'

# start the engines
mate.listen 3000
