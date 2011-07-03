mate = require '../../../lib/coffeemate'

mate.get '/', -> @render 'posts/index'
