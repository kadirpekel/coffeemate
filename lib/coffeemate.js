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
  eco = require('eco');

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
 * extension point that provides a relative base path for templates
 *
 * @api public
 */
CoffeemateContext.prototype.basepath = ''

/*
 * This method renders the template that read from given templateName
 * using eco template engine. It uses async file read operation to obtain
 * template contents
 *
 * @param {String} templateName
 * @param {String} dirname (optional)
 * @api public
 */
CoffeemateContext.prototype.render = function (templateName, dirname) {
  var self = this;
  var templatePath = path.join(dirname || process.cwd(), self.basepath, templateName);
  fs.readFile(templatePath, function (err, template) {
    if(err) throw err;
    self.resp.end(eco.render(template.toString(), self));
  });
};

/*
 * This method renders and includes the partial template that read and rendered
 * from given partial template name.
 *
 * @param {Function} partialName
 * @return {String}
 * @api public
 */
CoffeemateContext.prototype.include = function include (partialName) {
  var partialPath = path.join(process.cwd(), this.basepath, partialName);
  var partial = fs.readFileSync(partialPath);
  return eco.render(partial.toString(), this);
}

/*
 * Coffeemate core object
 * Kindly extends connect.HTTPServer and pours some sugar on it.
 *
 * @api private
 */
function Coffeemate () {
  this.options = {};
  this.routes = [];
  if (process.env.COFFEEMATE_USE_SSL && process.env.COFFEEMATE_USE_SSL == 'true') {
    connect.HTTPSServer.call(this, []);
  } else {
    connect.HTTPServer.call(this, []);
  }
}

/*
 * Bind a connect.HTTPServer instance to the prototype chain.
 */
Coffeemate.prototype.__proto__ = connect.HTTPServer.prototype;

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
 * override 'connect.HTTPServer.use' method so if any argument is a Coffeemate instance
 * build its internal route stack as a self used middleware.
 *
 * @param {String|Function}
 * @param {Function} handle
 * @return {Server}
 * @api public
 */
Coffeemate.prototype.use = function () {
  var args = Array.prototype.slice.call(arguments)
  args.forEach(function (arg) {
    if (arg instanceof Coffeemate) {
      arg.buildRouter();
    }
  });
  connect.HTTPServer.prototype.use.apply(this, args);
};

/*
 * Build connect router middleware from internal route stack and return as a gateway.
 * @api private
 */
Coffeemate.prototype.buildRouter = function () {
  var self = this;
  self.use(connect.router(function (app) {
    self.routes.forEach(function (route) {
      app[route.method].call(app, route.pattern, 
        function(req, resp, next) {
          return new self.Context(self, req, resp).callback(route);
        });
    });
  }));
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
  this.buildRouter();
  return connect.HTTPServer.prototype.listen.apply(this, arguments);
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