connect = require('connect');
coffeescript = require('coffee-script');
coffeekup = require('coffeekup');
fs = require('fs');

function RequestContext(req, resp, next) {
  this.req = req;
  this.resp = resp;
  this.next = next;
}

RequestContext.prototype.callback = function (route) {
  var self = this;
  return new function () {
    return route.callback.apply(self);
  }
};

RequestContext.prototype.render = function (templateName) {
  var self = this;
  fs.readFile(__dirname + '/' + templateName, function (err, data) {
    self.resp.end(coffeekup.render(data.toString(), {context: self}));
  });
};

function Coffeemate () {
  var self = this;
  self.options = {};
  self.routes = [];
  connect.router.methods.forEach(function (method) {
    self[method] = function (pattern, callback) {
      self.routes.push({method: method, pattern: pattern, callback: callback});
      return self;
    };
  });
}

Coffeemate.prototype.__proto__ = connect();

Coffeemate.prototype.listen = function () {
  var self = this;
  self.use(connect.router(function (app) {
    self.routes.forEach(function (route) {
      app[route.method].call(app, route.pattern, 
        function(req, resp, next) {
          return new RequestContext(req, resp, next).callback(route);
        });
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
};

module.exports = new Coffeemate;