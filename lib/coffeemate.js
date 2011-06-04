fs = require('fs');
path = require('path');
connect = require('connect');
coffeekup = require('coffeekup');

function CoffeemateContext(req, resp, next) {
  this.req = req;
  this.resp = resp;
  this.next = next;
}

CoffeemateContext.prototype.callback = function (route) {
  var self = this;
  return new function () {
    return route.callback.apply(self);
  }
};

CoffeemateContext.helpers = {
  include: function include (partialName) {
    var partialPath = path.join(process.cwd(), partialName);
    var partial = fs.readFileSync(partialPath);
    text(coffeekup.render(partial.toString(), {context: ck_options.context, locals: ck_options.locals}));
  }
}

CoffeemateContext.prototype.render = function (templateName) {
  var self = this;
  var templatePath = path.join(process.cwd(), templateName);
  fs.readFile(templatePath, function (err, template) {
    if(err) throw err;
    var options = {context: self, locals: CoffeemateContext.helpers};
    self.resp.end(coffeekup.render(template.toString(), options));
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
          return new CoffeemateContext(req, resp, next).callback(route);
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