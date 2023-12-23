#!/usr/bin/env ruby

require 'bindata'
require 'pp'

class TSD_Record_V2 < BinData::Record
  endian :little

  struct :tsd_data do 
    uint64 :timestamp
    uint32 :millisTime
    uint8  :state
    uint8  :hwFlags
    uint8  :swFlags
    uint8  :alertLevel
    uint16 :alertCount
    uint16 :motionCount
    uint16 :micCount
    uint16 :vDDH
    uint16 :vBat
    uint16 :vSys
    uint16 :vIn
    uint16 :iChg
    int16  :tempCore
    int16  :tempAlt
    int16  :x
    int16  :y
    int16  :z
    int16  :tareX
    int16  :tareY
    int16  :tareZ
    uint8  :heartRate
    uint8  :breathRate
    uint8  :chargeStat
    uint8  :zoneCount
    float_le    :zAngle
    float_le    :zPitch
    float_le    :zRoll

    uint64 :pauseUntilTime
    uint32 :resetReason
    uint16 :heapFree
    uint16 :paddingOne
    uint32 :accelSampleCount
    uint32 :accelSamplePersisted
    uint32 :sensorTimeMillis
    uint16 :numSamples
    uint8  :odrSize
    uint8  :fifoFlags

    uint16 :breathRateErrors
    uint16 :breathRateNonPeak

    uint16 :dcOffset
    uint16 :dcOffsetBinCount

    array :fftRank, initial_length: 10 do
      uint16 :bin
      uint16 :magnitude
    end
  end

  def pretty_print(pp)
    tsd_data.each_pair do |k, v|
      pp.text "#{k}:".ljust(20)
      pp.text "#{v}\n"
    end
  end
end

puts "Hello World"

file      = File.open("./test_data/test3.bin")
pp header = TSD_Record_V2.read(file)
