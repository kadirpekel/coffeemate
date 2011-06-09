sys       = require 'sys'
fs        = require 'fs'
path      = require 'path'
connect   = require 'connect'
eco       = require 'eco'

class CoffeemateContext
  
  basepath: ''
  
  constructor: (@container, @req, @resp) ->
    
  __callback: (route) -> route.callback.apply @
  
  redirect: (location) ->
    @resp.writeHead 301, location: location
    @resp.end()
  
  render: (templateName) ->
    templatePath = path.join process.cwd(), @basepath, templateName
    fs.readFile templatePath, (err, template) =>
      if err then throw err
      @resp.end eco.render "#{template}", @
    
  include: (partialName) ->
    partialPath = path.join process.cwd(), @basepath, partialName
    partial = fs.readFileSync partialPath
    eco.render "#{partial}", @

class Coffeemate extends connect.HTTPServer
  
  Context: CoffeemateContext
  context: CoffeemateContext::
  middleware: connect.middleware
  
  constructor: () ->
    @options = []
    @routes = []
    connect.HTTPServer.call @, []
  
  newInstance: () ->
    new Coffeemate
  
  use: (args...) ->
    arg.buildRouter for arg in args if arg instanceof Coffeemate
    connect.HTTPServer::use.apply @, args
  
  buildRouter: () ->
    @use @middleware.router (app) =>
      for route in @routes
        app[route.method] route.pattern, (req, resp) =>
          new CoffeemateContext(@, req, resp).__callback(route)
    
  listen: (args...) ->
    @buildRouter()
    connect.HTTPServer::listen.apply @, args

for item of Coffeemate::middleware
  do (item) ->
    Coffeemate::[item] = (args...) ->
      @use @middleware[item].apply @, args

for method in Coffeemate::middleware.router.methods
  do (method) ->
    Coffeemate::[method] = (pattern, callback) ->
      @routes.push method: method, pattern: pattern, callback: callback
      return @

process.on 'uncaughtException', (err) ->
  console.error(if err instanceof Error then err.stack else err)

module.exports = new Coffeemate