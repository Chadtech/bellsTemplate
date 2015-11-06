cp = require 'child_process'

module.exports = (what, output, seed) ->
  cmd = './convolve '
  cmd += what + ' ' + seed
  cmd += ' ' + output + ' 0.25'
  cp.execSync cmd