#!/usr/bin/env ruby

require 'pp'
require 'bindata'
require 'date'
require 'yaml'

class Unique_ID < BinData::Record
  endian :little
  uint32 :val1
  uint32 :val2
  uint32 :val3
  uint32 :val4

  def pretty_print(pp)
    #pp.text "#{val1.to_s(16)
    pp.text "0x"
    pp.text "%.8x" % val4
    pp.text "%.8x" % val3
    pp.text "%.8x" % val2
    pp.text "%.8x" % val1
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

# Find address of all SDAT from /dev/disk2s1 or /dev/disk2 (minus 8192 * 512)

file_offsets = [
  "00ef0000",
  "00ef4000",
  "03930000",
  "03938000",
  "03960000",
  "03968000",
  "03970000",
  "03978000",
  "03980000",
  "03988000",
  "03a00000",
  "03a08000",
  "03a18000",
  "03a20000",
  "04068000",
  "04070000",
  "04388000",
  "04390000",
  "04690000",
  "04698000",
  "046a0000",
  "046a8000",
  "04c30000",
  "04c38000",
  "04f08000",
  "04f10000",
  "04f18000",
  "04f20000",
  "050e8000",
  "050f0000",
  "050f8000",
  "05100000",
  "05110000",
  "05118000",
  "05518000",
  "05520000",
  "05528000",
  "05530000",
  "05570000",
  "05578000",
  "05af0000",
  "05af8000",
  "05b60000",
  "05b68000",
  "06450000",
  "06458000",
  "06470000",
  "06478000",
  "06480000",
  "06488000",
  "06548000",
  "06550000",
  "066e0000",
  "066e8000",
  "06928000",
  "06930000",
  "06cb0000",
  "06cb8000",
  "06cc0000",
  "06cc8000",
  "06d18000",
  "06d20000",
  "06d30000",
  "06d38000",
  "06d40000",
  "06d48000",
  "06d58000",
  "06d60000",
  "07338000",
  "07340000",
  "078f8000",
  "07900000",
  "07ea8000",
  "07eb0000",
  "084f8000",
  "08500000",
  "08d40000",
  "08d48000",
  "08f10000",
  "08f18000",
  "09598000",
  "095a0000",
  "09b80000",
  "09b88000",
  "0a028000",
  "0a030000",
  "0a370000",
  "0a378000",
  "0a960000",
  "0a968000",
  "0ad90000",
  "0ad98000",
  "0b398000",
  "0b3a0000",
  "0b798000",
  "0b7a0000",
  "0b8e8000",
  "0b8f0000",
  "0bd50000",
  "0bd58000",
  "0c0d0000",
  "0c0d8000",
  "0c440000",
  "0c448000",
  "0c460000",
  "0c468000",
  "0ca88000",
  "0ca90000",
  "0cc90000",
  "0cc98000",
  "0cf10000",
  "0cf18000",
  "0d0e8000",
  "0d0f0000",
  "0d570000",
  "0d578000"
]

file_offsets2 = [
  0x00ef0000,
  0x00ef4000,
  0x03930000,
  0x03938000,
  0x03960000,
  0x03968000,
  0x03970000,
  0x03978000,
  0x03980000,
  0x03988000,
  0x03a00000,
  0x03a08000,
  0x03a18000,
  0x03a20000,
  0x04068000,
  0x04070000,
  0x04388000,
  0x04390000,
  0x04690000,
  0x04698000,
  0x046a0000,
  0x046a8000,
  0x04c30000,
  0x04c38000,
  0x04f08000,
  0x04f10000,
  0x04f18000,
  0x04f20000,
  0x050e8000,
  0x050f0000,
  0x050f8000,
  0x05100000,
  0x05110000,
  0x05118000,
  0x05518000,
  0x05520000,
  0x05528000,
  0x05530000,
  0x05570000,
  0x05578000,
  0x05af0000,
  0x05af8000,
  0x05b60000,
  0x05b68000,
  0x06450000,
  0x06458000,
  0x06470000,
  0x06478000,
  0x06480000,
  0x06488000,
  0x06548000,
  0x06550000,
  0x066e0000,
  0x066e8000,
  0x06928000,
  0x06930000,
  0x06cb0000,
  0x06cb8000,
  0x06cc0000,
  0x06cc8000,
  0x06d18000,
  0x06d20000,
  0x06d30000,
  0x06d38000,
  0x06d40000,
  0x06d48000,
  0x06d58000,
  0x06d60000,
  0x07338000,
  0x07340000,
  0x078f8000,
  0x07900000,
  0x07ea8000,
  0x07eb0000,
  0x084f8000,
  0x08500000,
  0x08d40000,
  0x08d48000,
  0x08f10000,
  0x08f18000,
  0x09598000,
  0x095a0000,
  0x09b80000,
  0x09b88000,
  0x0a028000,
  0x0a030000,
  0x0a370000,
  0x0a378000,
  0x0a960000,
  0x0a968000,
  0x0ad90000,
  0x0ad98000,
  0x0b398000,
  0x0b3a0000,
  0x0b798000,
  0x0b7a0000,
  0x0b8e8000,
  0x0b8f0000,
  0x0bd50000,
  0x0bd58000,
  0x0c0d0000,
  0x0c0d8000,
  0x0c440000,
  0x0c448000,
  0x0c460000,
  0x0c468000,
  0x0ca88000,
  0x0ca90000,
  0x0cc90000,
  0x0cc98000,
  0x0cf10000,
  0x0cf18000,
  0x0d0e8000,
  0x0d0f0000,
  0x0d570000,
  0x0d578000
]

bytes_per_sector = 512
reserved_sectors = 32
number_of_fats = 2
sectors_of_fat = "3ba0".to_i(16)
sectors_per_cluster = 32
bytes_per_cluster = sectors_per_cluster * bytes_per_sector
starting_cluster = 2
fat_entry_bytes = 4


puts sectors_of_fat
puts bytes_per_cluster

fat_offset = reserved_sectors * bytes_per_sector
fat_section_size = sectors_of_fat * number_of_fats * bytes_per_sector
data_start = fat_offset + fat_section_size
data_base  = fat_offset + (sectors_of_fat * number_of_fats * bytes_per_sector) -  2 * bytes_per_cluster

puts "Offset of FAT table : 0x #{fat_offset.to_s(16)}"
puts "Offset of Cluster 2 : 0x #{data_start.to_s(16)}"
puts "Offset of Cluster 0 : 0x #{data_base.to_s(16)}"

# Seek to FAT offset
test_offset = 0x00eec000

file_offsets.each do |addr|
  fat_entry_num = (addr.to_i(16) - data_start) / 16384 + 2
  fat_entry_offset = fat_offset + fat_entry_bytes * (fat_entry_num - 1)
  puts "File offset: #{addr}, FAT Entry: #{fat_entry_num}, Entry Offset: 0x#{fat_entry_offset.to_s(16)}, #{(fat_entry_offset & 0xFFFFFFF0).to_s(16)}"
end


# FatStartSector = BPB_ResvdSecCnt
# FatSectors = BPB_FATSz * BPB_NumFATs

# RootDirStartSector = FatStartSector + FatSectors
# RootDirSectors = (32 * BPB_RootEntCnt + BPB_BytsPerSec - 1) / BPB_BytsPerSec

# DataStartSector = RootDirStartSector + RootDirSectors
# DataSectors = BPB_TotSec - DataStartSector

# CountofClusters = DataSectors / BPB_SecPerClus
# A volume with count of clusters <=4085 is FAT12.
# A volume with count of clusters >=4086 and <=65525 is FAT16.
# A volume with count of clusters >=65526 is FAT32.

# irb(main):024:0> ("ef0000".to_i(16) - ((512 * 32) + (512 * 15264 * 2))) / 16384 + 2
# => 3
# irb(main):025:0> ((512 * 32) + (512 * 15264 * 2)  + (16384 * (3-2))).to_s(16) 
# => "ef0000"

#source = File.open("/dev/disk2s1", "rb")
source = File.open("/Users/jgartrel/Documents/Arduino/Sopor_Ear_Low_Power_OTA/save/sd_data2/fat32_info/non_working_disk/fat_32_w_dir4.bin", "r")

file_offsets.each do |addr|
  fat_entry_num = (addr.to_i(16) - data_start) / 16384 + 2
  fat_entry_offset = fat_offset + fat_entry_bytes * (fat_entry_num - 1)
  puts "File offset: #{addr}, FAT Entry: #{fat_entry_num}, Entry Offset: 0x#{fat_entry_offset.to_s(16)}, #{(fat_entry_offset & 0xFFFFFFF0).to_s(16)}"
  # Read header
  source.seek(addr.to_i(16), IO::SEEK_SET)
  tsd_data = TSD_Data.new
  tsd_data.read(source)
  #####header = IO.binread("testfile", 128, addr.to_i(16)) 
  #header = source.read(128)
  #pp header.chars.map { |x| x.ord.to_s(16) } 
  pp tsd_data
  pp tsd_data.header.boardID

  #tare_bytes = ""
  #tare_bytes += "%.4x" % tsd_data.header.tareX
  #tare_bytes += "%.4x" % tsd_data.header.tareY
  #tare_bytes += "%.4x" % tsd_data.header.tareZ

  tare_bytes = ""
  tare_bytes += tsd_data.header.tareX.to_binary_s
  tare_bytes += tsd_data.header.tareY.to_binary_s
  tare_bytes += tsd_data.header.tareZ.to_binary_s

  pp tare_bytes
  
  
  # Compute filename
  # filename = 1702163107
  #pp Time.at(tsd_data.header.timestamp).to_datetime
  ts = Time.at(tsd_data.header.timestamp).utc.to_datetime
  #filename = ts.strftime('%y%m%d00.') + " + tsd_data.dataID[0..2]
  filename = ""
  puts Dir.pwd
  100.times do |n|
    filename = "%6.6s%02d.%.3s" % [ ts.strftime('%y%m%d'), n, tsd_data.dataID ]
    break if ( ! File.exist?(filename) )
  end
  if (f = File.open(filename, "wb"))
    puts "Creating Filename: #{filename}"
    tsd_data.write(f)
  else
    puts "ERROR: Unable to open filename: #{filename}"
    exit
    next
  end
  
  # Read Tare values

  sdat_tare_offset = addr.to_i(16) + tsd_data.header.tareX.abs_offset
  source.seek(data_start, IO::SEEK_SET)
  cluster_count = 2 
  fragment_db = []
  data_db = []
  while (buf = source.read(bytes_per_cluster)) do
    cluster_offset = data_base + cluster_count * bytes_per_cluster
    #puts "Cluster: #{cluster_count}, 0x%08x" % cluster_offset
    pos = 0 
    while (pos = buf.index(tare_bytes, pos)) do
      if ( cluster_offset + pos == sdat_tare_offset)
        #puts "TSD tare, cluster: %d, pos: %d" % [ cluster_count, pos ]
        pos += tare_bytes.length
        next
      end
      record_start = pos - 42
      pos = record_start + tsd_data.recordSize 
      remaining_bytes = bytes_per_cluster - pos
      if (remaining_bytes < 48 && remaining_bytes > 0)
        fragment = {
          :timestamp => buf.slice(pos,8).unpack('V*').first,
          :cluster   => cluster_count,
          :pos       => pos,
          :size      => remaining_bytes,
          :data      => buf.slice(pos,remaining_bytes),
          :type      => 1
        }
        fragment_db.push(fragment) 
        #puts ""
        #pp fragment
        #puts "Possible remnant, cluster: %d, pos: %d, size: %d" % [ cluster_count, pos, remaining_bytes  ]
      end
      if (record_start < 0)
        fragment = {
          :timestamp => buf.slice(pos,8).unpack('V*').first,
          :cluster   => cluster_count,
          :pos       => 0,
          :size      => pos,
          :data      => buf.slice(0,pos),
          :type      => 4
        }
        fragment_db.push(fragment) 
        #puts ""
        #pp fragment
        #puts "TSD runt, cluster: %d, pos: %d" % [ cluster_count, record_start ]
        next
      end
      if (record_start < 112 && record_start > 0)
        fragment = {
          :timestamp => buf.slice(record_start,8).unpack('V*').first,
          :cluster   => cluster_count,
          :pos       => 0,
          :size      => record_start,
          :data      => buf.slice(0,record_start),
          :type      => 3
        }
        if buf.slice(0,4) == "SDAT" || buf.slice(0,4) == "TADS"
          fragment[:type] = 5
          next
        end
        fragment_db.push(fragment) 
        #puts ""
        #pp fragment
        #puts "TSD runt, cluster: %d, pos: %d" % [ cluster_count, record_start ]
        next
      end
      current_record = buf.slice(record_start, tsd_data.recordSize) 
      if ( current_record.length != tsd_data.recordSize )
        fragment = {
          :timestamp => buf.slice(record_start,8).unpack('V*').first,
          :cluster   => cluster_count,
          :pos       => record_start,
          :size      => current_record.length,
          :data      => current_record,
          :type      => 2
        }
        fragment_db.push(fragment) 
        #puts ""
        #pp fragment
        #puts "TSD runt, cluster: %d, pos: %d, size: %d" % [ cluster_count, record_start, current_record.length  ]
        next
      end
      #puts "TSD: 0x%08x" % [ cluster_offset + record_start ] 
      datum = {
        :timestamp => buf.slice(record_start,8).unpack('V*').first,
        :cluster   => cluster_count,
        :pos       => record_start,
        :size      => current_record.length,
        :data      => current_record,
        :type      => 0 
      }
      data_db.push(datum) 
      print "."
    end
    cluster_count += 1
  end

  # Search for all occurances of Tare value
  # 42 bytes before start of tare
  # 102 bytes after start of tare
  # record offset and timestamp for each record
  # order by timestamp (4 bytes at beginning of record)
  # Write chunks to file in order
  puts "(EOF)"

  fragments_recovered = 0
  data2_db = []
  unpaired_db = []
  fragment_db.sort_by!{ |h| h[:timestamp] }
  # pp({}.merge(fragment_db[0]))
  #fragment_db.each { |h| pp {}.merge(h) }
  fragment_db.each { |h| pp({}.merge(h).delete_if{|k,v| k == :data}) }
  while ( fragment = fragment_db.shift )
    if ( fragment_next = fragment_db[0] ) 
      if ( (fragment_next[:timestamp] - fragment[:timestamp] < 10) &&
           (fragment[:type] + fragment_next[:type] == 5) &&
           (fragment[:size] + fragment_next[:size] == tsd_data.recordSize) )
        fragment[:data] += fragment_next[:data]
        fragment[:size] += fragment_next[:size]
        if data_db.detect{ |h| h[:timestamp] == fragment[:timestamp] }
          puts "Avoid Duplicate:"
          pp({}.merge(fragment).delete_if{|k,v| k == :data})
        else
          data_db.push(fragment)
          fragments_recovered += 1
        end
        fragment_db.shift
        next
      end
    end
    unpaired_db.push(fragment)
  end
  #puts ""
  #data2_db.sort_by!{ |h| h[:timestamp] }
  #data2_db.each { |h| pp({}.merge(h).delete_if{|k,v| k == :data}) }
  puts ""
  unpaired_db.sort_by!{ |h| h[:timestamp] }
  unpaired_db.each { |h| pp({}.merge(h).delete_if{|k,v| k == :data}) }
  puts ""
  unpaired_db.each do |fragment|
    puts "Checking Timestamp: #{fragment[:timestamp]}"
    pp data_db.select { |h| h[:timestamp] == fragment[:timestamp] }
  end
  File.open(filename + ".yml", "w") { |file| file.write(unpaired_db.to_yaml) }
  puts ""
  data_db.sort_by!{ |h| h[:timestamp] }
  ts_duration = 0
  ts_prev = 0
  tsd_prev = {}
  data_db.each_with_index do |tsd,i|
    if tsd[:timestamp] == 0
      pp({}.merge(tsd).delete_if{|k,v| k == :data})
      next 
    end
    if tsd[:data] == tsd_prev[:data]
      puts "Skipping Duplicate: #{tsd[:timestamp]}"
      next
    end
    if tsd[:timestamp] == ts_prev
      puts "Duplicate Timestamp:"
      pp tsd_prev
      pp tsd
      puts ""
    end
    if tsd[:timestamp] == 1702181423
      puts "Timestamp 1702181423:"
      pp({}.merge(tsd).delete_if{|k,v| k == :data})
      pp({}.merge(data_db[i-1]).delete_if{|k,v| k == :data})
      puts ""
    end
    unless f.write(tsd[:data]) == tsd_data.recordSize
      puts "Invalid data size:"
      pp tsd
    end
    ts_prev = tsd[:timestamp]
    tsd_prev = tsd
    ts_duration = tsd[:timestamp] - tsd_data.header.timestamp
  end
  puts ""
  ts_gaps = 0
  ts_prev = tsd_data.header.timestamp
  tsd_prev = {}
  puts "TSD gaps:"
  data_db.each do |tsd|
    next if tsd[:timestamp] == 0
    delta_time = tsd[:timestamp] - ts_prev
    if delta_time > 12
      pp({:delta => delta_time}.merge(tsd).delete_if{|k,v| [:data,:size,:type].include?(k)})
      ts_gaps += 1
    end
    ts_prev = tsd[:timestamp]
  end
  puts ""
  puts "Timestamp gap count : #{ts_gaps}"
  puts "Timestamp duration  : #{ts_duration} seconds"
  puts "Fragments recovered : #{fragments_recovered}"
  puts "Fragments discarded : #{unpaired_db.length}"
  puts "Total data points written: #{data_db.length}"
  exit
end
