Nt  = require './noitech.coffee'
gen = Nt.generate
eff = Nt.effect
say = require './say.coffee'


octavesOfBellJ = []
thisOctave     = []

say 'Loading Bells'

for bellIndex in [0 .. 44 ]

  bellNumber = bellIndex % 5
  bellNumber += ''
  bellNumber = (bellIndex // 5) + bellNumber

  filePath = './bellJ/bellJ' + bellNumber
  filePath += '.wav'

  thisBellSound = Nt.open filePath
  thisBellSound = Nt.convertToFloat thisBellSound[0]
  thisBellSound = eff.vol thisBellSound, factor: 0.25
  
  thisOctave.push thisBellSound

  if (bellIndex % 5) is 4
    octavesOfBellJ.push thisOctave

    thisOctave = []


octavesOfBellK = []
thisOctave     = []

for bellIndex in [0 .. 44 ]

  bellNumber = bellIndex % 5
  bellNumber += ''
  bellNumber = (bellIndex // 5) + bellNumber

  filePath = './BellK/BellK' + bellNumber
  filePath += '.wav'

  thisBellSound = Nt.open filePath
  thisBellSound = Nt.convertToFloat thisBellSound[0]
  thisBellSound = eff.vol thisBellSound, factor: 0.25
  
  thisOctave.push thisBellSound

  if (bellIndex % 5) is 4
    octavesOfBellK.push thisOctave

    thisOctave = []


voice0 =
  '10': octavesOfBellJ[2][0]
  '11': octavesOfBellJ[2][1]
  '12': octavesOfBellJ[2][2]
  '13': octavesOfBellJ[2][3]
  '14': octavesOfBellJ[2][4]
  '20': octavesOfBellJ[3][0]
  '21': octavesOfBellJ[3][1]
  '22': octavesOfBellJ[3][2]
  '23': octavesOfBellJ[3][3]
  '24': octavesOfBellJ[3][4]
  '30': octavesOfBellJ[4][0]
  '31': octavesOfBellJ[4][1]
  '32': octavesOfBellJ[4][2]
  '33': octavesOfBellJ[4][3]
  '34': octavesOfBellJ[4][4]

voice1 =
  '10': octavesOfBellJ[2][0]
  '11': octavesOfBellJ[2][1]
  '12': octavesOfBellJ[2][2]
  '13': octavesOfBellJ[2][3]
  '14': octavesOfBellJ[2][4]
  '20': octavesOfBellJ[3][0]
  '21': octavesOfBellJ[3][1]
  '22': octavesOfBellJ[3][2]
  '23': octavesOfBellJ[3][3]
  '24': octavesOfBellJ[3][4]
  '30': octavesOfBellJ[4][0]
  '31': octavesOfBellJ[4][1]
  '32': octavesOfBellJ[4][2]
  '33': octavesOfBellJ[4][3]
  '34': octavesOfBellJ[4][4]

voice2 =
  '10': octavesOfBellJ[2][0]
  '11': octavesOfBellJ[2][1]
  '12': octavesOfBellJ[2][2]
  '13': octavesOfBellJ[2][3]
  '14': octavesOfBellJ[2][4]
  '20': octavesOfBellJ[3][0]
  '21': octavesOfBellJ[3][1]
  '22': octavesOfBellJ[3][2]
  '23': octavesOfBellJ[3][3]
  '24': octavesOfBellJ[3][4]
  '30': octavesOfBellJ[4][0]
  '31': octavesOfBellJ[4][1]
  '32': octavesOfBellJ[4][2]
  '33': octavesOfBellJ[4][3]
  '34': octavesOfBellJ[4][4]


voice3 =
  '31': octavesOfBellK[4][1]
  '32': octavesOfBellK[4][2]
  '33': octavesOfBellK[4][3]
  '34': octavesOfBellK[4][4]
  '40': octavesOfBellK[5][0]
  '41': octavesOfBellK[5][1]
  '42': octavesOfBellK[5][2]
  '43': octavesOfBellK[5][3]
  '44': octavesOfBellK[5][4]
  '50': octavesOfBellK[6][0]
  '51': octavesOfBellK[6][1]
  '52': octavesOfBellK[6][2]
  '53': octavesOfBellK[6][3]
  '54': octavesOfBellK[6][4]
  '60': octavesOfBellK[7][0]

voice4 =
  '31': octavesOfBellK[4][1]
  '32': octavesOfBellK[4][2]
  '33': octavesOfBellK[4][3]
  '34': octavesOfBellK[4][4]
  '40': octavesOfBellK[5][0]
  '41': octavesOfBellK[5][1]
  '42': octavesOfBellK[5][2]
  '43': octavesOfBellK[5][3]
  '44': octavesOfBellK[5][4]
  '50': octavesOfBellK[6][0]
  '51': octavesOfBellK[6][1]
  '52': octavesOfBellK[6][2]
  '53': octavesOfBellK[6][3]
  '54': octavesOfBellK[6][4]
  '60': octavesOfBellK[7][0]

voice5 =
  '31': octavesOfBellK[4][1]
  '32': octavesOfBellK[4][2]
  '33': octavesOfBellK[4][3]
  '34': octavesOfBellK[4][4]
  '40': octavesOfBellK[5][0]
  '41': octavesOfBellK[5][1]
  '42': octavesOfBellK[5][2]
  '43': octavesOfBellK[5][3]
  '44': octavesOfBellK[5][4]
  '50': octavesOfBellK[6][0]
  '51': octavesOfBellK[6][1]
  '52': octavesOfBellK[6][2]
  '53': octavesOfBellK[6][3]
  '54': octavesOfBellK[6][4]
  '60': octavesOfBellK[7][0]






voices =  [
  voice0
  voice1
  voice2
  voice3
  voice4
  voice5
]

module.exports = voices