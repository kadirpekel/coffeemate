var sys = require('sys'),
  fs = require('fs');
  path = require('path');
  connect = require('connect');
  coffeekup = require('coffeekup');

function CoffeemateContext(container, req, resp) {
  this.req = req;
  this.resp = resp;
  this.container = container;
}

CoffeemateContext.prototype.redirect = function (location) {
  this.resp.writeHead(301, {'Location': location});
  this.resp.end();
};

CoffeemateContext.prototype.callback = function (route) {
  var self = this;
  return new function () {
    return route.callback.apply(self);
  }
};

CoffeemateContext.prototype.render = function (templateName) {
  var self = this;
  var templatePath = path.join(process.cwd(), templateName);
  fs.readFile(templatePath, function (err, template) {
    if(err) throw err;
    var options = {context: self, locals: self.container.helpers};
    self.resp.end(coffeekup.render(template.toString(), options));
  });
};

function Coffeemate (options) {
  this.options = options || {};
  this.routes = [];
}

Coffeemate.prototype.__proto__ = connect();

Coffeemate.prototype.newInstance = function (options) {
  return new Coffeemate(options);
}

Coffeemate.prototype.Context = CoffeemateContext

Coffeemate.prototype.context = CoffeemateContext.prototype;

Coffeemate.prototype.middleware = connect.middleware;

Coffeemate.prototype.helpers = {
  include: function include (partialName) {
    var partialPath = path.join(process.cwd(), partialName);
    var partial = fs.readFileSync(partialPath);
    text(coffeekup.render(partial.toString(), {context: ck_options.context, locals: ck_options.locals}));
  }
};

Coffeemate.prototype.listen = function () {
  var self = this;
  self.use(connect.router(function (app) {
    self.routes.forEach(function (route) {
      app[route.method].call(app, route.pattern, 
        function(req, resp, next) {
          return new self.Context(self, req, resp).callback(route);
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
      arguments
  );
};

Object.keys(connect.middleware).forEach(function (item) {
  Coffeemate.prototype[item] = function () {
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    var middleware = connect.middleware[item].apply(self, arguments);
    self.use(middleware);
    return middleware;
  }
});

connect.router.methods.forEach(function (method) {
  Coffeemate.prototype[method] = function (pattern, callback) {
    var self = this;
    self.routes.push({method: method, pattern: pattern, callback: callback});
    return self;
  };
});

process.on('uncaughtException', function (err) {
  sys.error(err instanceof Error ? err.stack : err);
});

module.exports = new Coffeemate;