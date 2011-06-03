connect = require('connect')

function Coffeemate () {
  var self = this;
  self.routes = [];
  connect.router.methods.forEach(function (method) {
    self[method] = function () {
      self.routes.push({method: method, args: Array.prototype.slice.call(arguments)});
      return self;
    }
  });
}

Coffeemate.prototype.__proto__ = connect();

Coffeemate.prototype.listen = function () {
  var self = this;
  self.use(connect.router(function (app) {
    self.routes.forEach(function (route) {
      app[route.method].apply(app, route.args);
    });
  }));
  return connect.HTTPServer.prototype.listen.apply(
    connect(
      function (req, resp, next) {
        resp.setHeader('X-Powered-By', self.constructor.name);
        next();
        },
      self),
      Array.prototype.slice.call(arguments)
  );
}

module.exports = new Coffeemate;
