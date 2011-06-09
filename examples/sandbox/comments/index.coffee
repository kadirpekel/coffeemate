mate = require('../../../lib/coffeemate').newInstance()

mate.get '/', -> @view 'list'

module.exports = mate