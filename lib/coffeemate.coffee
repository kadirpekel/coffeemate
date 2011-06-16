# coffeemate
# Copyright(c) 2011 Kadir Pekel.
# MIT Licensed

# Module dependencies

sys       = require 'sys'
fs        = require 'fs'
path      = require 'path'
connect   = require 'connect'
eco       = require 'eco'

# Context object that instantiated in every request to
# form router handlers' and templates'  @/this reference
class CoffeemateContext
  # constructor
  #
  # @param {Object} container
  # @param {Object} resp
  # @param {Object} resp
  # @api public
  constructor: (@container, @req, @resp) ->
  
  # Simple built-in extension that sends http redirect to client
  #
  # @param {String} location
  # @api public
  redirect: (location) ->
    @resp.writeHead 301, location: location
    @resp.end()

  # This method renders the template that read from given templateName
  # using eco template engine. It uses async file read operation to obtain
  # template contents
  #
  # @param {String} templateName
  # @api public
  render: (templateName) ->
    templatePath = path.join process.cwd(),
      @container.options.renderDir,
      "#{templateName}#{@container.options.renderExt}"
    fs.readFile templatePath, (err, template) =>
      if err then throw err
      @resp.end @container.options.renderFunc "#{template}", @
  
  # This method renders and includes the partial template that read and rendered
  # from given partial template name.
  #
  # @param {String} partialName
  # @return {String}
  # @api public
  include: (partialName) ->
    partialPath = path.join process.cwd(),
      @container.options.renderDir,
      "#{partialName}#{@container.options.renderExt}"
    partial = fs.readFileSync partialPath
    @container.options.renderFunc "#{partial}", @

# Coffeemate core object
# Kindly extends connect.HTTPServer and pours some sugar on it.
#
# @api private
class Coffeemate extends connect.HTTPServer
  
  # Expose CoffeemateContext constructor for external access
  Context: CoffeemateContext
  
  # Shorthand reference for CoffeemateContext.prototype to simplify the extension mechanism
  context: CoffeemateContext::
  
  # Expose connect's built-in middleware stack explicitly for external access
  middleware: connect.middleware
  
  # constructor
  #
  # @api public
  constructor: () ->
    @options = renderFunc: eco.render, renderDir: '', renderExt: ''
    @routes = []
    connect.HTTPServer.call @, []

  # Factory method for creating new Coffeemate instances
  # 
  # @return {Object}
  # @api public
  newInstance: () ->
    new Coffeemate
  
  # Override 'connect.HTTPServer.use' method so if any argument is a Coffeemate instance
  # build its internal route stack as a self used middleware.
  # 
  # @param {String|Function}
  # @param {Function} handle
  # @return {Server}
  # @api public
  use: (args...) ->
    arg.buildRouter() for arg in args when arg instanceof Coffeemate
    connect.HTTPServer::use.apply @, args
  
  # sugarize coffeekup!
  #
  # @api public
  coffeekup: ->
    renderFunc = require('coffeekup').render
    @options.renderFunc = (tmpl, ctx) -> renderFunc tmpl, context: ctx

  # Build connect router middleware from internal route stack and automatically use it.
  # 
  # @api private
  buildRouter: () ->
    @use @middleware.router (app) =>
      for route in @routes
        do (route) =>
          app[route.method] route.pattern, (req, resp) =>
            route.callback.apply new CoffeemateContext(@, req, resp)

  # Override 'connect.HTTPServer.listen' to create a pre-hook space for
  # preparing router definitions
  # 
  # @param {Number} port
  # @param {String} hostname
  # @param {Function} callback
  # @api public
  listen: (args...) ->
    @buildRouter()
    connect.HTTPServer::listen.apply @, args

# Create shorthand middleware definitions using connect's built-in middleware stack
for item of Coffeemate::middleware
  do (item) ->
    Coffeemate::[item] = (args...) ->
      @use @middleware[item].apply @, args

# Create shorthand router definitions using connect's router middleware
for method in Coffeemate::middleware.router.methods
  do (method) ->
    Coffeemate::[method] = (pattern, callback) ->
      @routes.push method: method, pattern: pattern, callback: callback
      @

# Handle uncaught exceptions explicitly to prevent node exiting
# current process. Exception stack trace is sent to stderr.
process.on 'uncaughtException', (err) ->
  console.error(if err instanceof Error then err.stack else err)

# Export Coffeemate as a pre-instantiated instance
# use 'newInstance' method to create another ones
module.exports = new Coffeemate