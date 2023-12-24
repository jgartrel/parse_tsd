#!/usr/bin/env ruby

require 'bindata'
require 'pp'

class Unique_ID < BinData::Record
  endian :little
  uint32 :val1
  uint32 :val2
  uint32 :val3
  uint32 :val4

  def to_s
    "0x%.8x%.8x%.8x%.8x" % [val4, val3, val2, val1]
  end

  def pretty_print(pp)
    pp.text self.to_s
  end

  def snapshot
    self.to_s
  end

end

class TSD_Header < BinData::Record
  endian :little

  uint64    :timestamp
  int8      :timezoneOffset
  string    :gitVersion, length: 63, trim_padding: true
  unique_id :boardID
  uint32    :serialNum
  int16     :tareX
  int16     :tareY
  int16     :tareZ
  uint8     :alertMode
  uint8     :emptyPaddingOne
  uint32    :uptimeMillis
end

class TSD_Data < BinData::Record
  endian :little

  string     :fileID, length: 4
  uint32     :fileVersion
  uint32     :headerSize
  uint32     :emptyPadding
  tsd_header :header
  string     :dataID, length: 4
  uint32     :recordSize
end

class TSD_Record_V2 < BinData::Record
  endian :little

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

  def pretty_print(pp)
    self.each_pair do |k, v|
      pp.text "#{k}:".ljust(20)
      pp.text "#{v}\n"
    end
  end

  def self.csv_header
    csv_row = []
    self.new.snapshot.each_pair do |k,v|
      if v.respond_to?(:each_with_index)
        v.each_with_index do |member,i|
        csv_row.push("#{k}#{i}")
      end
      else
        csv_row.push("#{k}")
      end
    end
    csv_row
  end

  def to_csv
    h = self.snapshot
    [
      "%d" % h[:timestamp],
      "%d" % h[:millisTime],
      "%d" % h[:state],
      "0x%02X" % h[:hwFlags],
      "0x%02X" % h[:swFlags],
      "%d" % h[:alertLevel],
      "%d" % h[:alertCount],
      "%d" % h[:motionCount],
      "%d" % h[:micCount],
      "%d" % h[:vDDH],
      "%d" % h[:vBat],
      "%d" % h[:vSys],
      "%d" % h[:tempCore],
      "%d" % h[:tempAlt],
      "%d" % h[:x],
      "%d" % h[:y],
      "%d" % h[:z],
      "%d" % h[:tareX],
      "%d" % h[:tareY],
      "%d" % h[:tareZ],
      "%d" % h[:heartRate],
      "%d" % h[:breathRate],
      "%d" % h[:zoneCount],
      "%0.2f" % h[:zAngle],
      "%0.2f" % h[:zPitch],
      "%0.2f" % h[:zRoll],

      "%d" % h[:pauseUntilTime],
      "0x%08X" % h[:resetReason],
      "%d" % h[:heapFree],
      "%d" % h[:accelSampleCount],
      "%d" % h[:accelSamplePersisted],
      "%d" % h[:sensorTimeMillis],
      "%d" % h[:numSamples],
      "0x%02X" % h[:odrSize],
      "0x%02X" % h[:fifoFlags],
      "%d" % h[:breathRateErrors],
      "%d" % h[:breathRateNonPeak],
      "%d" % h[:dcOffset],
      "%d" % h[:dcOffsetBinCount],
      "%d" % (h[:fftRank][0][:bin] + h[:fftRank][0][:magnitude] * 65536),
      "%d" % (h[:fftRank][1][:bin] + h[:fftRank][1][:magnitude] * 65536),
      "%d" % (h[:fftRank][2][:bin] + h[:fftRank][2][:magnitude] * 65536),
      "%d" % (h[:fftRank][3][:bin] + h[:fftRank][3][:magnitude] * 65536),
      "%d" % (h[:fftRank][4][:bin] + h[:fftRank][4][:magnitude] * 65536),
      "%d" % (h[:fftRank][5][:bin] + h[:fftRank][5][:magnitude] * 65536),
      "%d" % (h[:fftRank][6][:bin] + h[:fftRank][6][:magnitude] * 65536),
      "%d" % (h[:fftRank][7][:bin] + h[:fftRank][7][:magnitude] * 65536),
      "%d" % (h[:fftRank][8][:bin] + h[:fftRank][8][:magnitude] * 65536),
      "%d" % (h[:fftRank][9][:bin] + h[:fftRank][9][:magnitude] * 65536),
    ].join(",")
  end
end

if ARGV.empty?
  $stderr.puts "Usage: #{File.basename($0)} <infile.TSD>"
  exit 1
end

infile = ARGV.shift

file = File.open(infile)
PP.pp(tsd_data = TSD_Data.read(file), $stderr)

raise "Unknown Version" unless tsd_data.dataID == "TSD\x02"
raise "Record Size Mismatch" unless tsd_data.recordSize == TSD_Record_V2.new.num_bytes

csv_row = TSD_Record_V2.csv_header

csv_row += [
  "%d" % tsd_data.header.timestamp,
  "%d" % tsd_data.header.timezoneOffset,
  "%d" % tsd_data.header.uptimeMillis,
  "%s" % tsd_data.header.gitVersion,
  "%s" % tsd_data.header.boardID,
  "%d" % tsd_data.header.serialNum,
  "%d" % tsd_data.header.alertMode,
]
puts csv_row.join(",")

record_count = 0
while tsd = TSD_Record_V2.read(file)
  #pp tsd.snapshot
  puts tsd.to_csv
  record_count += 1
  break
end

$stderr.puts "\n#{record_count} record(s) exported\n"

file.close
