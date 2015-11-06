cp = require 'child_process'

module.exports = (what) ->
  cp.execSync 'say ' + what