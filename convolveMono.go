package main

import (
    // "bufio"
    "fmt"
    // "io"
    // "io/ioutil"
    "strconv"
    "os"
    // "math"
)


func check(e error){
  if e != nil {
    panic(e)
  }
}


func convolver( audio []int, convolveSeed []int, factor float64) []int {

  lengthOfOutput := len(audio) + len(convolveSeed)
  output := make( []int, lengthOfOutput )

  for outputIndex := 0; outputIndex < lengthOfOutput; outputIndex++ {
    output[ outputIndex ] = 0
  }

  for audioIndex := 0; audioIndex < len(audio); audioIndex++ {

    atAudioIndex := float64(audio[ audioIndex ])
    if atAudioIndex > 32767 {
      atAudioIndex -= 65535
    }


    for convolveIndex := 0; convolveIndex < len(convolveSeed); convolveIndex++ {

      atConvolveIndex := float64(convolveSeed[ convolveIndex ])
      if atConvolveIndex > 32767 {
        atConvolveIndex -= 65535
      }

      factor := (atConvolveIndex / 32767 ) * factor
      output[ convolveIndex + audioIndex ] += int(atAudioIndex * factor )

    }

  }

  for outputIndex := 0; outputIndex < lengthOfOutput; outputIndex++ {
    if (output[ outputIndex ] < 0){
      output[ outputIndex] += 65535
    }
  }

  return output
}



func readStereoWAV( openFileName string ) [][]int{

  readFile, err := os.Open( openFileName )
  check(err)
  readFile.Seek(40, 0)

  var sizeOfAudioBuffer int64 = 0
  durationByte                := make([]byte, 4)

  readFile.Read( durationByte )

  sizeOfAudioBuffer += int64(durationByte[0])
  sizeOfAudioBuffer += 256 * int64(durationByte[1])
  sizeOfAudioBuffer += 65536 * int64(durationByte[2])
  sizeOfAudioBuffer += 16777216 * int64(durationByte[3])
  durationOfAudio   := int64(sizeOfAudioBuffer / 4)

  output    := make([][]int, 2 )
  output[0] =  make([]int, durationOfAudio)
  output[1] =  make([]int, durationOfAudio)


  for datumIndex := int64(0); datumIndex < (durationOfAudio); datumIndex++ {


      thisSampleByte := make([]byte, 2)
      readFile.Read( thisSampleByte )

      output[0][ datumIndex ] = 0
      output[0][ datumIndex ] += int(thisSampleByte[ 0 ])
      output[0][ datumIndex ] += int(thisSampleByte[ 1 ]) * 256
  

      thisSampleByte = make([]byte, 2)
      readFile.Read( thisSampleByte )

      output[1][ datumIndex ] = 0
      output[1][ datumIndex ] += int(thisSampleByte[ 0 ])
      output[1][ datumIndex ] += int(thisSampleByte[ 1 ]) * 256

  }
  return output
}



func readMonoWAV( openFileName string ) []int{

  readFile, err := os.Open( openFileName )
  check(err)
  readFile.Seek(40, 0)

  var sizeOfAudioBuffer int64 = 0
  durationByte                := make([]byte, 4)

  readFile.Read( durationByte )

  sizeOfAudioBuffer += int64(durationByte[0])
  sizeOfAudioBuffer += 256 * int64(durationByte[1])
  sizeOfAudioBuffer += 65536 * int64(durationByte[2])
  sizeOfAudioBuffer += 16777216 * int64(durationByte[3])
  durationOfAudio   := int64(sizeOfAudioBuffer / 2)

  output := make([]int, durationOfAudio)

  for datumIndex := int64(0); datumIndex < (durationOfAudio); datumIndex++ {

    thisSampleByte := make([]byte, 2)
    readFile.Read( thisSampleByte )

    output[ datumIndex ] = 0
    output[ datumIndex ] += int( thisSampleByte[ 0 ] )
    output[ datumIndex ] += int( thisSampleByte[ 1 ] ) * 256

  }

  return output

}


func main() {

  fmt.Println( "Reading Wavs")
  wavFile           := readMonoWAV( os.Args[1] )
  convolveSeed      := readMonoWAV( os.Args[2] )
  factor            := os.Args[4]
  factorFloat, err  := strconv.ParseFloat(factor, 64)


  fmt.Println("Convolving Mono Channel")
  wavFile = convolver( wavFile, convolveSeed, factorFloat )
  // fmt.Println( "Convolving Right Channel")
  // wavFile[1] = convolver( wavFile[1], convolveSeed, factorFloat )


  savedFile, err := os.Create( os.Args[3] )
  check(err)


  fmt.Println( "Saving File")
  wavHeader := make([]byte, 44)

  wavHeader[0] = 82
  wavHeader[1] = 73
  wavHeader[2] = 70
  wavHeader[3] = 70

  wavHeader[4] = 36
  wavHeader[5] = 8
  wavHeader[6] = 0
  wavHeader[7] = 0

  wavHeader[8]  = 87
  wavHeader[9]  = 65
  wavHeader[10] = 86
  wavHeader[11] = 69

  wavHeader[12] = 102
  wavHeader[13] = 109
  wavHeader[14] = 116
  wavHeader[15] = 32
 
  wavHeader[16] = 16
  wavHeader[17] = 0
  wavHeader[18] = 0
  wavHeader[19] = 0

  wavHeader[20] = 1
  wavHeader[21] = 0
  wavHeader[22] = 1
  wavHeader[23] = 0

  wavHeader[24] = 68
  wavHeader[25] = 172
  wavHeader[26] = 0
  wavHeader[27] = 0

  wavHeader[28] = 68
  wavHeader[29] = 172
  wavHeader[30] = 0
  wavHeader[31] = 0

  wavHeader[32] = 4
  wavHeader[33] = 0
  wavHeader[34] = 16
  wavHeader[35] = 0

  wavHeader[36] = 100
  wavHeader[37] = 97
  wavHeader[38] = 116
  wavHeader[39] = 97

  wavHeader[40] = byte(len(wavFile) % 256)
  wavHeader[41] = byte(len(wavFile) / 256)
  wavHeader[42] = byte(len(wavFile) / 4096)
  wavHeader[43] = byte(len(wavFile) / 65536)

  wavData := make([]byte, (len(wavFile)) * 2)

  for audioIndex := 0; audioIndex < len(wavFile); audioIndex++ {

    wavData[  audioIndex * 2      ] = byte(wavFile[ audioIndex ] % 256)
    wavData[ (audioIndex * 2) + 1 ] = byte(wavFile[ audioIndex ] / 256)
  }

  savedFile.Write(wavHeader)
  savedFile.Write(wavData)

  savedFile.Close()
}

