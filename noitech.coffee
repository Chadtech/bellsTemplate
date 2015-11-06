fs        = require 'fs'
generate  = require './generate'
effect    = require './effect'

module.exports =

  generate: generate
  effect: effect


  convertTo64Bit: (input) ->

    sampleIndex = 0

    while sampleIndex < input.length
      input[sampleIndex] = (input[sampleIndex] * 32767) // 1
      sampleIndex++
      
    input


  convertToFloat: (input) ->
    sampleIndex = 0
    while sampleIndex < input.length
      input[sampleIndex] = input[sampleIndex] / 32767
      sampleIndex++
      
    input


  buildFile: (fileName, channels) ->

    manipulatedChannels = channels
    sameLength = true
    
    # The channels all have to be the same length, check to see if thats the case before proceeding

    # Step 0
    # Compare each possible channel combination, and dont do so redunantly:

    #         C0   C1   C2   C3   C4
    #     C0        X    X    X    X
    #     C1             X    X    X
    #     C2                  X    X
    #     C3                       X
    #     C4

    #     X := a sensible pair to compare

    channelIndex = 0
    while channelIndex < channels.length
      relativeChannel = 0
      while relativeChannel < (channels.length - channelIndex)
        channelsLength = channels[channelIndex].length
        otherChannelsLength = channels[relativeChannel + channelIndex].length
        if channelsLength isnt otherChannelsLength
          sameLength = false
        relativeChannel++
      channelIndex++

    # Step 1
    # If weve established that the channels are not the same length find out
    # how long the longest channel is (A). Then pad the shorter channels with
    # silence (B)

    if not sameLength
      longestChannelsLength = 0

      # (A)
      for channel in channels
        if channel.length > longestChannelsLength
          longestChannelsLength = channel.length

      # (B)
      for channel in channels
        lengthDifference = 0
        while lengthDifference < (longestChannelsLength - channel.length)
          channel.push 0
          lengthDifference++

    # Make an Array, so that the audio samples can be aggregated in 
    # the standard way wave files are (For each sample i in channels a, b, 
    #and c, the sample order goes a(i),b(i),c(i),a(i+1),b(i+1),c(i+1), ... )

    # A number being negative cannot be designated in the data.
    # For negative amplitudes, we save the absolute value of
    # the negative amplitude minus the 2 ** 16

    # Thus 
    #
    #        *
    #    *       *
    #  *           *
    # *  ---------  *  -----------
    #                *           *
    #                  *       *
    #                      * 
    #                       
    # Is saved as (A)
    #                *           *
    #                  *       *
    #                      * 
    #                       
    #        *
    #    *       *
    #  *           *
    # *  ---------  *  -----------

    channelAudio = []
    sampleIndex = 0
    while sampleIndex < channels[0].length
      channelIndex = 0
      while channelIndex < channels.length
        valueToAdd = 0
        if channels[channelIndex][sampleIndex] < 0
          # (A)
          valueToAdd = channels[channelIndex][sampleIndex] + 65536
        else
          valueToAdd = channels[channelIndex][sampleIndex]
        channelAudio.push (valueToAdd % 256)
        channelAudio.push (valueToAdd // 256)
        channelIndex++
      sampleIndex++
    
    # Make an array containing all the header information, 
    #like sample rate, the size of the file, 
    #the samples themselves etc
    header = []
    
    # 'RIFF' in decimal
    header = header.concat [
      82
      73
      70
      70
    ]

    # The size of the channels audio, plus the size of the header containing
    # this information (36)
    thisWavFileSize = (channels[0].length * 2 * channels.length) + 36
    
    wavFileSizeZE = thisWavFileSize % 256
    wavFileSizeON = (thisWavFileSize // 256) % 256
    wavFileSizeTW = (thisWavFileSize // 65536) % 256
    wavFileSizeTH = (thisWavFileSize // 16777216) % 256

    # This is the size of the file
    header = header.concat [
      wavFileSizeZE
      wavFileSizeON
      wavFileSizeTW
      wavFileSizeTH
    ]

    # 'WAVE' in decimal
    header = header.concat [
      87
      65
      86
      69
    ]

    # 'fmt[SQUARE]' in decimal
    header = header.concat [
      102
      109
      116
      32
    ]

    # The size of the subchunk after this chunk of data
    header = header.concat [
      16
      0
      0
      0
    ] 

    # The second half of this datum is the number of channels
    header = header.concat [ 
      1
      0
      channels.length % 256
      Math.floor(channels / 256)
    ]

    # The maximum number of channels is 65535
    # Sample Rate 44100.
    header = header.concat [
      44100 % 256
      44100 // 256
      0
      0
    ]

    byteRate = 44100 * channels.length * 2
    byteRateZE = byteRate % 256
    byteRateON = (byteRate // 256) % 256
    byteRateTW = (byteRate // 65536) % 256
    byteRateTH = (byteRate // 16777216) % 256

    header = header.concat [
      byteRateZE
      byteRateON
      byteRateTW
      byteRateTH
    ]

    # The first half is the block align (2*number of channels), 
    # the second half is te bits per sample (16)
    header = header.concat [ 
      channels.length * 2
      0
      16
      0
    ]

    # 'data' in decimal
    header = header.concat [
      100
      97
      116
      97
    ]

    sampleDataSize = channels.length * channels[0].length * 2
    sampleDataSizeZE = sampleDataSize % 256
    sampleDataSizeON = (sampleDataSize // 256) % 256
    sampleDataSizeTW = (sampleDataSize // 65536) % 256
    sampleDataSizeTH = (sampleDataSize // 16777216) % 256

    header = header.concat [
      sampleDataSizeZE
      sampleDataSizeON
      sampleDataSizeTW
      sampleDataSizeTH
    ]

    filesData = header.concat(channelAudio)
    outputFile = new Buffer(filesData)
    fs.writeFileSync fileName, outputFile



  open: (fileName) ->

    data = []
    rawFile = fs.readFileSync fileName 

    datumIndex = 0
    while datumIndex < rawFile.length
      data.push rawFile.readUInt8 datumIndex 
      datumIndex++

    numberOfChannels = data[22]
    unsortedAudioData = []

    sampleIndex = 44
    while sampleIndex < data.length
      if sampleIndex % 2 is 0
        if rawFile[sampleIndex + 1] >= 128
          datum = data[sampleIndex + 1] * 256
          datum += data[sampleIndex]
          datum = 65536 - datum
          datum *= -1
          unsortedAudioData.push datum
        else
          datum = data[sampleIndex + 1] * 256
          datum += data[sampleIndex]
          unsortedAudioData.push datum
      sampleIndex++

    channels = []
    channelIndex = 0
    while channelIndex < numberOfChannels
      channels.push []
      sampleIndex = 0
      while sampleIndex < (unsortedAudioData.length / numberOfChannels)
        sample = unsortedAudioData[ (sampleIndex * numberOfChannels) + channelIndex ]
        channels[ channels.length - 1].push sample
        sampleIndex++
      channelIndex++

    channels



  mix: (input0, input1, place, safe) ->
    whereAt = place or 0

    if safe
      si = 0
      while si < input0.length
        if (si + whereAt) < input1.length
          input1[ whereAt + si ] += input0[ si ]
        else
          input1.push input0[ si ]
        si++

    else
      sampleIndex = 0
      while sampleIndex < input0.length
        input1[whereAt + sampleIndex] += input0[sampleIndex]
        sampleIndex++

    input1


  displace: (input0, input1, place) ->
    whereAt = place or 0

    sampleIndex = 0
    while sampleIndex < input0.length
      input1[whereAt + sampleIndex] = input0[sampleIndex]
      sampleIndex++

    input1



  join: (input0, input1) ->
    output = []

    for sample in input0
      output.push sample

    for sample in input1
      output.push sample

    output



  split: (input, at) ->
    output0 = []
    output1 = []

    sampleIndex = 0
    while sampleIndex < at
      output0.push input[sampleIndex]
      sampleIndex++
      
    while sampleIndex < input.length
      output1.push input[sampleIndex]
      sampleIndex++

    [output0, output1]








