require 'benchmark'
require 'fileutils'
require 'excon'
require 'pry'

# module Arome
# end

# create a random spot
class Spot
  attr_accessor :x, :y

  def initialize
    @x = rand(-2.0..10.0).ceil(4)
    @y = rand(40.0..48.0).ceil(4)
  end
end

# create a config file
class Configuration
  attr_accessor :server, :cache_dir, :wgrib2_path

  def initialize
    @server = 'https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/'
    @cache_dir = '/tmp/arome'
    @wgrib2_path = 'wgrib2'
    # @records = {
    #     :rain => "RPRATE/",
    #     :tmp   => "TMP/",
    #     :ugrd  => "UGRD/",
    #     :vgrd  => "VGRD/",
    #     :vgust  => "VGUST/",
    #     :ugust  => "UGUST/",
    #   }
  end
end

# create a list of spot
def create_rand_spot
  spot_list = []
  100.times {
      spot_list << @spot = Spot.new
    }
  spot_list
end

# call on wgrib2
# create a list of coord to add to wgrib script

def create_list(spot_list)
  list = ""
  spot_list.each { |spot|
    list += "-lon #{spot.x} #{spot.y} -nl "
  }
  list
end

def run_hour
  now = Time.now.utc
  run = Time.utc(now.year, now.month, now.day, (now.hour / 6) * 6)
  @run = run - 6 * 3600
end

# def date_today
#   d = Time.now
#   @year = d.year
#   @month = d.month
#   @day = 25 #d.day
#   format("%04d-%02d-%02d/%02d", @year, @month, @day, @run_hour)
# end


def create_data_file(list)
  cmd = "wgrib2"
  path = "../datameteofrance/arome-france-hd_20210919_12_TMP_2m_0h.grib2"
  options = "-nl"
  res = `#{cmd} #{path} #{list} #{options}`
end

# list.nil? ? list = "-lon #{lon} #{lat} -nl" : list += "-lon #{lon} #{lat} -nl"
# list
# spot_list = create_rand_spot

# list = create_list(spot_list)
# puts create_data_file(list)
# puts config.cache_dir
# puts run_hour.hour
# date_today

def dirname
  config = Configuration.new
  subdir = format("%04d-%02d-%02d/%02d", @run.year, @run.month, @run.day, @run.hour)
  # param = '/UGRD/10m/'
  File.join(config.cache_dir, subdir)
end

def date_run_format
  format("%04d-%02d-%02d/%02d", @run.year, @run.month, @run.day, @run.hour)
end

url = 'https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/2021-09-26/12/UGRD/10m/0h.grib2'

# puts FileUtils.mkpath(dirname)
# puts fetch_arome(url)
run_hour
# puts @run
# puts dirname

# def availability_data
#   #date
#   # d = Time.now
#   now = Time.now.utc
#   run = Time.utc(now.year, now.month, now.day, (now.hour / 6) * 6)
#   run - 6 * 3600

  #create url
# end
# https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/2021-09-26/12/RPRATE/surface/acc_0-1h.grib2

url = 'https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/2021-09-25/12/RPRATE/surface/acc_0-1h.grib2'
# https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/2021-09-25/12/RPRATE/surface/acc_0-42h.grib2

def fetch_arome(url)
  config = Configuration.new
  filename = url.gsub('https://mf-nwp-models.s3.amazonaws.com',"#{config.cache_dir}")
  path = filename.split('/')[0...-1].join('/')

  FileUtils.mkpath(path)

  streamer = lambda do |chunk, remaining_bytes, total_bytes|
    File.open("#{filename}", "ab") { |f| f.write(chunk) } #création du fichier de stockage
    puts "Remaining: #{remaining_bytes.to_f / total_bytes}%"
  end

  puts filename

  begin
    res = Excon.get("#{url}", :response_block => streamer)
  rescue Excon::Errors::Error
    raise "Download of '#{url}' failed"
  end
end

def test
  config = Configuration.new
  # binding.pry
  param = ['RPRATE/surface/acc_0-','UGRD/10m/','VGRD/10m/','VGUST/10m/','UGUST/10m/','TMP/2m/']
#,,'UGRD/10m/','VGRD/10m/' // 'VGUST/10m/','UGUST/10m/','TMP/2m/','RPRATE/surface/acc_0-'
  @run.hour == 00 | 12 ? x = 42 : x = 36 # Runs 00 & 12: up to 42h Runs 06 & 18: up to 36h

  param.each { |par|
    if par == 'VGUST/10m/' ||'UGUST/10m/' || 'RPRATE/surface/acc_0-' then x -= 1 end
    (0..x).each.with_index { |x,index|
         if par == 'VGUST/10m/' ||'UGUST/10m/' || 'RPRATE/surface/acc_0-' then index += 1 end
      url = "#{config.server}#{date_run_format}/#{par}#{index}h.grib2"
      fetch_arome(url) }
    }
  end
  D = Time.now
  test
  F = Time.now
  puts (D-F)
# fetch_arome(url)
# puts availability_data.hour
# streamer = lambda do |chunk, remaining_bytes, total_bytes|
#  chunk
#   puts "Remaining: #{remaining_bytes.to_f / total_bytes}%"
# end

# puts res = Excon.get('https://mf-nwp-models.s3.amazonaws.com/arome-france-hd/v2/2021-09-25/12/UGRD/10m/0h.grib2', :response_block => streamer)

# # def read_values
# end


# def mylist
#   mylist = ""
#   500.times {
  #     # mylist += 10
#     mylist += "-lon -2.72 48.52 -nl -lon -2.6 48.00 -lon -1.72 48.52 -nl -lon -2 48.00 "
#   }
#   mylist
# end
# mylist = "-ij 1000 1000 -grid_id "

# list = ""
# # mylist
# puts tent = Spot.new
# puts tent.x
# puts tent.y


# puts mylist
# puts mylist.inspect

# puts Benchmark.measure {
#   1000.times {
#    res
#    }
#   }

#AROME
#verif la dispo des donnees
#choisir le type de donnees a telecharger
#telecharger les donnes
#stocker les donnes
#lister les spots
#extraire les données de

##contrainte
#ouvrir une fois le fichier grib /heurehttps://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/https://mf-models-on-aws.org/#arome-france-hd/v2/2021-09-25/00/

#resultat
# pour un ou plusieurs point GPS, je veux les données météo choisis (vent, direction, couverture nuageuse, pluie) dans un JSON?
#point gps ; heure : parametre : variable

