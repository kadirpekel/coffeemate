# coffeemate
# Copyright(c) 2011 Kadir Pekel.
# MIT Licensed

# version info
VERSION = '0.4.1'

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
  # @param {Object} cnt (container coffeemate instance)
  # @param {Object} resp
  # @param {Object} resp
  # @api public
  constructor: (@cnt, @req, @resp) ->
  
  # Simple built-in extension that sends http redirect to client
  #
  # @param {String} location
  # @api public
  redirect: (location) ->
    @resp.writeHead 301, location: location
    @resp.end()
      
  # This method renders the template that read from given templateName
  # using eco template engine as default.
  # It uses sync file read operation to obtain template contents
  #
  # @param {String} templateName
  # @return {String}
  # @api public
  include: (templateName) ->
    templatePath = path.join process.cwd(), @cnt.options.renderDir, "#{templateName}#{@cnt.options.renderExt}"
    template = fs.readFileSync templatePath
    @cnt.options.renderFunc "#{template}", @

  # This method renders the template that read from given templateName
  # and writes the output to the client socket stream
  #
  # You can explicitly set 'layoutName' if want to override the default 
  # 'renderLayoutName' option value
  #
  # @param {String} templateName
  # @param {String} layoutName
  # @api public
  render: (templateName, layoutName=@cnt.options.renderLayoutName, layout=@cnt.options.renderLayout) ->
    @[@cnt.options.renderLayoutPlaceholder] = templateName
    templateName = layout and layoutName or templateName
    @resp.end @include templateName

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
  constructor: (@version=VERSION) ->
    @options = renderFunc: eco.render, renderDir: '', renderExt: '.eco', renderLayout: yes, renderLayoutName: 'layout', renderLayoutPlaceholder: 'body'
    @routeMap = {}
    @baseUrl = '/'
    connect.HTTPServer.call @, []
    
    # enable socket.io if available
    try @io = require('socket.io').listen @
  
  # This method helps you define sub applications under given base path.
  # The context of callback is coffeemate instance itself and any router definition
  # in this context will be constructed based on the baseUrl
  #
  # @param {String} baseUrl
  # @param {String} callback
  # @api public
  sub: (baseUrl, callback) ->
    previousBaseUrl = @baseUrl
    @baseUrl = baseUrl
    callback.call @
    @baseUrl = previousBaseUrl

  # Factory method for creating new Coffeemate instances
  # 
  # @return {Object}
  # @api public
  newInstance: ->
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
  
  # Enable special coffeekup templating magic!
  #
  # @api public
  coffeekup: (locals) ->
    renderFunc = require('coffeekup').render
    locals ?= {}
    locals.include ?= (partialName) -> text ck_options.context.include partialName    
    @options.renderFunc = (tmpl, ctx) -> renderFunc tmpl, context: ctx, locals: locals

  # Build connect router middleware from internal route stack and automatically use it.
  # 
  # @api private
  buildRouter: ->
    self = @
    for root, routes of @routeMap
      @use root, @middleware.router (app) ->
        for route in routes
          do (route) ->
            app[route.method] route.pattern, (req, resp) ->
              route.callback.apply new CoffeemateContext(self, req, resp)

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
      @routeMap[@baseUrl] ?= []
      @routeMap[@baseUrl].push method: method, pattern: pattern, callback: callback
      @

# Handle uncaught exceptions explicitly to prevent node exiting
# current process. Exception stack trace is sent to stderr.
process.on 'uncaughtException', (err) ->
  console.error err instanceof Error and err.stack or err

# Export Coffeemate as a pre-instantiated instance
# use 'newInstance' method to create another ones
module.exports = new Coffeemate
