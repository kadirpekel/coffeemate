mate = require('../../../lib/coffeemate').newInstance()

mate.get '/', -> @view 'home'

module.exports = mate