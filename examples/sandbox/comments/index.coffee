mate = require '../../../coffeemate'

mate.get '/', -> @render 'comments/index', 'comment_layout'
