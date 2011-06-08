/*!
 * coffeemate
 * Copyright(c) 2011 Kadir Pekel.
 * MIT Licensed
 */

/**
 * Module dependencies
 */
var sys = require('sys'),
  fs = require('fs'),
  path = require('path'),
  connect = require('connect'),
  coffeekup = require('coffeekup');

/*
 * Context object that instantiated in every request to
 * form router handlers' and templates'  @/this reference
 * @param {Object} container
 * @param {Object} resp
 * @param {Object} resp
 * @api public
 */
function CoffeemateContext(container, req, resp) {
  this.req = req;
  this.resp = resp;
  this.container = container;
}

/*
 * Simple built-in extension that sends http redirect to client
 *
 * @param {String} location
 * @api public
 */
CoffeemateContext.prototype.redirect = function (location) {
  this.resp.writeHead(301, {'Location': location});
  this.resp.end();
};

/*
 * This is a special method for internal use that binds 
 * route handler to current CoffeemateContext instance.
 * @param {Function} route
 * @return {Function}
 * @api private
 */
CoffeemateContext.prototype.callback = function (route) {
  var self = this;
  return new function () {
    return route.callback.apply(self);
  }
};

/*
 * This is a special method for internal use that binds 
 * the incoming route handler to the current CoffeemateContext instance.
 * @param {Function} route
 * @return {Function}
 * @api private
 */
CoffeemateContext.prototype.render = function (templateName) {
  var self = this;
  var templatePath = path.join(process.cwd(), templateName);
  fs.readFile(templatePath, function (err, template) {
    if(err) throw err;
    var options = {context: self, locals: self.container.helpers};
    self.resp.end(coffeekup.render(template.toString(), options));
  });
};

/*
 * Coffeemate core object
 * Kindly extends connect.HTTPServer and pours some sugar on it.
 *
 * @api private
 */
function Coffeemate () {
  this.options = {};
  this.routes = [];
}

/*
 * Bind a connect.HTTPServer instance to the prototype chain.
 */
Coffeemate.prototype.__proto__ = connect();

/*
 * Factory method for creating new Coffeemate instances
 *
 * @return {Object}
 * @api public
 */
Coffeemate.prototype.newInstance = function () {
  return new Coffeemate();
}

/*
 * Expose CoffeemateContext constructor for external access
 */
Coffeemate.prototype.Context = CoffeemateContext

/*
 * Shorthand reference for CoffeemateContext.prototype to simplify 
 * the extension mechanism
 */
Coffeemate.prototype.context = CoffeemateContext.prototype;

/*
 * Expose connect's built-in middleware stack explicitly for external access
 */
Coffeemate.prototype.middleware = connect.middleware;

/*
 * Helpers stack with a pre-packed 'include' helper. Helper functions runs in
 * coffeekup rendering context so if you get stuck with it please go read coffeekup's
 * code or documentation.
 */
Coffeemate.prototype.helpers = {
  include: function include (partialName) {
    var partialPath = path.join(process.cwd(), partialName);
    var partial = fs.readFileSync(partialPath);
    text(coffeekup.render(partial.toString(), {context: ck_options.context, locals: ck_options.locals}));
  }
};

/*
 * Override 'connect.HTTPServer.listen' to create a pre-hook space for
 * preparing router definitions
 * @param {Number} port
 * @param {String} hostname
 * @param {Function} callback
 * @api public
 */
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

/*
 * Create shorthand middleware definitions using connect's built-in middleware stack
 */
Object.keys(connect.middleware).forEach(function (item) {
  Coffeemate.prototype[item] = function () {
    var self = this;
    var args = Array.prototype.slice.call(arguments);
    var middleware = connect.middleware[item].apply(self, arguments);
    self.use(middleware);
    return middleware;
  }
});

/*
 * Create shorthand router definitions using connect's router middleware
 */
connect.router.methods.forEach(function (method) {
  Coffeemate.prototype[method] = function (pattern, callback) {
    var self = this;
    self.routes.push({method: method, pattern: pattern, callback: callback});
    return self;
  };
});

/*
 * Handle uncaught exceptions explicitly to prevent node exiting
 * current process. Exception stack trace is sent to stderr.
 */
process.on('uncaughtException', function (err) {
  sys.error(err instanceof Error ? err.stack : err);
});

/*
 * export Coffeemate as a pre-instantiated instance
 * use 'newInstance' method to create another ones
 */
module.exports = new Coffeemate;