module.exports = 
  
  getFileName: (filePath) ->
    index = filePath.length - 1 
    while filePath[ index ] isnt '/'
      index--
    filePath.substring index + 1, filePath.length

  removeFileExtension: (fileName) ->
    index = 0
    while fileName[ index ] isnt '.'
      index++
    fileName.substring 0, index

  getFileExtension: (fileName) ->
    index = fileName.length - 1
    while (fileName[ index ] isnt '.') and index isnt 0
      index--
    fileName.substring index, fileName.length