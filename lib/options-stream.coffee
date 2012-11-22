fs = require 'fs'
path = require 'path'
yaml = require 'yamljs'
ini = require 'ini'
ion = require 'ion/lib/ion-min'

merge = (o1, o2) ->
  for k of o2
    if typeof o2[k] is 'object' and o2[k] not instanceof Array and o2[k] not instanceof Buffer
      if typeof o1[k] isnt 'object' or o1[k] instanceof Array or o1[k] instanceof Buffer
        o1[k] = o2[k]
      else
        merge(o1[k], o2[k])
    else
      o1[k] = o2[k]
  o1

module.exports = (args...) ->
  c = {}
  freeze = false
  [args..., freeze] = args if typeof args[args.length-1] is 'boolean'

  for arg in args
    if typeof arg is 'string'
      merge c, switch path.extname arg
        when '.ini' then ini.parse fs.readFileSync(arg).toString()
        when '.json' then JSON.parse fs.readFileSync arg
        when '.yml', '.yaml' then yaml.parse fs.readFileSync(arg).toString().trim()
        when '.ion' then ion.parse fs.readFileSync(arg).toString().trim().replace /\n/igm, '\r\n'
    else if arg isnt undefined
      merge c, arg
  Object.freeze c if freeze
  c
