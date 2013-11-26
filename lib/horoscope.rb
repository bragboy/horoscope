require 'horoscope/version'
require 'horoscope/overrides/math_override'
require 'horoscope/planet'
require 'rmagick'

module Horoscope
  class Horo

    PLANETS = ["As", "Su", "Mo", "Ma", "Me", "Ju", "Ve", "Sa", "Ra", "Ke"]

    ERRORS = {
      :Date => "Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD",
      :Lat  => "Error: Invalid Latitude. Enter between -90.0 to +90.0",
      :Lon  => "Error: Invalid Longitude. Enter between -180.0 to +180.0"
    }

    attr_accessor :datetime, :lat, :lon, :errors, :positions

    def initialize(data={})
      @data = data

      @errors = []

      @datetime = data[:datetime]
      @zone = data[:offset]
      @lat = data[:lat]
      @lon = data[:lon]
      @positions = Hash[PLANETS.map {|x| [x, nil]}]
    end

    def compute
      return @errors if validate_values.size > 0 

      tpos = [10980, 16233, 15880, 16451, 15210, 13722, 13862, 7676, 4306, 15106]
      tsp, pos, spd = [Array.new(10, 0), Array.new(10, 0), Array.new(10, 0)]
      jd = Planet.get_jul_day(@datetime.month, @datetime.day, @datetime.year)
      time = @datetime.hour + (@datetime.min / 60.0)
      time -= @datetime.utc_offset / 3600.0
      jd += time / 24.0
      t = (jd - 0.5 - Planet::J2000) / 36525.0
      Planet.get_planets(t, pos, spd)
      pos[0] = Planet.ascendant(t, time, @lon, @lat)
      ayn = Planet.get_ayan(t)
      (0..9).each do |i|
        tpos[i] = ((pos[i] + ayn) % 360.0 * 60.0).to_i
        if tpos[i] < 0
          tpos = tpos
          n = i
          tpos[n] += 21600
        end
        tsp[i] = (spd[i] * 3600.0).to_i
      end
      (0..11).each do |i|
        (0..9).each do |j|
          @positions[PLANETS[j]] = i if (tpos[j] / 1800 == i)
        end
      end
      return @positions
    end

    def create_chart(options={})
      base_chart = Magick::ImageList.new('../assets/south_chart.png')
    end

    private

    def validate_values
      @errors = []
      @errors << ERRORS[:Date] if @datetime.nil? || !@datetime.is_a?(Time) || @datetime.year > 2300 || @datetime.year < 1600
      @errors << ERRORS[:Lat] if @lat.nil? || @lat > 90.0 || @lat < -90.0
      @errors << ERRORS[:Lon] if @lon.nil? || @lon > 180.0 || @lon < -180.0
      @errors
    end

  end
end
