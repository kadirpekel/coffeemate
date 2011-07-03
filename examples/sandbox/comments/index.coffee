mate = require '../../../lib/coffeemate'

mate.get '/', -> @render 'comments/index', 'comment_layout'
