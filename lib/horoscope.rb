require 'horoscope/version'
require 'horoscope/overrides/math_override'
require 'horoscope/planet'
require 'RMagick'

module Horoscope
  class Horo

    PLANETS = ["As", "Su", "Mo", "Ma", "Me", "Ju", "Ve", "Sa", "Ra", "Ke"]

    IMG_SIZE = 440
    SPLIT = IMG_SIZE/4
    XBIAS = 10
    YBIAS = 15
    PADDING = 15

    ERRORS = {
      :Date => "Error: Invalid Date. Enter a valid date between years 1600 AD and 2300 AD",
      :Zone => "Error: Please pass a valid time zone ranging from -12.0 to +12.0",
      :Lat  => "Error: Invalid Latitude. Enter between -90.0 to +90.0",
      :Lon  => "Error: Invalid Longitude. Enter between -180.0 to +180.0"
    }

    attr_accessor :datetime, :zone, :lat, :lon, :errors, :positions, :positions_rev

    def initialize(data={})
      @data = data

      @errors = []

      @computed = false
      @datetime = data[:datetime]
      @zone = data[:zone]
      @lat = data[:lat]
      @lon = data[:lon]
      @positions = Hash[PLANETS.map {|x| [x, nil]}]
      @positions_rev = [[], [], [], [], [], [], [], [], [], [], [], []]
    end

    def compute
      return @errors if validate_values.size > 0 

      tpos = [10980, 16233, 15880, 16451, 15210, 13722, 13862, 7676, 4306, 15106]
      tsp, pos, spd = [Array.new(10, 0), Array.new(10, 0), Array.new(10, 0)]
      jd = Planet.get_jul_day(@datetime.month, @datetime.day, @datetime.year)
      time = @datetime.hour + (@datetime.min / 60.0)
      time -= @zone
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
      count = 0
      (0..11).each do |i|
        (0..9).each do |j|
          if (tpos[j] / 1800 == i)
            @positions[PLANETS[j]] = i 
            @positions_rev[i] << PLANETS[j]
          end
        end
      end
      @computed = true
      return @positions
    end

    def create_chart(options={})
      self.compute unless @computed
      base_chart = Magick::ImageList.new('assets/south_chart.png')

      canvas = Magick::ImageList.new
      canvas.new_image(IMG_SIZE, IMG_SIZE, Magick::TextureFill.new(base_chart))

      draw_x = [XBIAS+SPLIT, XBIAS+SPLIT*2, XBIAS+SPLIT*3, XBIAS+SPLIT*3, XBIAS+SPLIT*3, XBIAS+SPLIT*3, XBIAS+SPLIT*2, XBIAS+SPLIT, XBIAS, XBIAS, XBIAS, XBIAS, XBIAS]
      draw_y = [YBIAS, YBIAS, YBIAS, YBIAS+SPLIT, YBIAS+SPLIT*2, YBIAS+SPLIT*3, YBIAS+SPLIT*3, YBIAS+SPLIT*3, YBIAS+SPLIT*3, YBIAS+SPLIT*2, YBIAS+SPLIT, YBIAS]

      text = Magick::Draw.new
      text.pointsize = 14
      text.font_family = 'helvetica'

      @positions_rev.each_with_index do |this_pos, i|
        unless this_pos.empty?
          this_pos.each_with_index do |planet, j|
            text.annotate(canvas, 0, 0, draw_x[i], draw_y[i] + j * PADDING, planet) {
              self.fill = planet == PLANETS[0] ? 'red' : 'black'
            }
          end
        end
      end
      x = canvas.write('output.png')
    end

    private

    def validate_values
      @errors = []
      @errors << ERRORS[:Date] if @datetime.nil? || !@datetime.is_a?(Time) || @datetime.year > 2300 || @datetime.year < 1600
      @errors << ERRORS[:Zone] if @zone.nil? || @zone > 12.0 || @zone < -12.0
      @errors << ERRORS[:Lat] if @lat.nil? || @lat > 90.0 || @lat < -90.0
      @errors << ERRORS[:Lon] if @lon.nil? || @lon > 180.0 || @lon < -180.0
      @errors
    end

  end
end
