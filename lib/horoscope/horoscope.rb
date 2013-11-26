class Horoscope

  PLANETS = ["As", "Su", "Mo", "Ma", "Me", "Ju", "Ve", "Sa", "Ra", "Ke"]

  attr_accessor :month, :day, :year, :zone, :hour, :min, :lat, :lon

  def initialize(data={})    
    @data = data

    @month = data[:month]
    @day = data[:day]
    @year = data[:year]
    @zone = data[:offset]
    @hour = data[:hour]
    @min = data[:min]
    @lat = data[:lan]
    @lon = data[:lon]
    @positions = Hash[PLANETS.map {|x| [x, nil]}]
  end

  def self.for_now
    @month = Time.now.month
    @day = Time.now.day
    @year = Time.now.year
    @zone = - Time.now.utc_offset / 60.0 / 60.0
    @hour = Time.now.hour
    @min = Time.now.min
    @lat = 0
    @lon = 0
    @positions = Hash[k.map {|x| [x, nil]}]
  end

  def compute
    tpos = [10980, 16233, 15880, 16451, 15210, 13722, 13862, 7676, 4306, 15106]
    tsp, pos, spd = [Array.new(10, 0), Array.new(10, 0), Array.new(10, 0)]
    jd = Planet.get_jul_day(@month, @day, @year)
    time = @hour + (@min / 60.0)
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
    (0..11).each do |i|
      (0..9).each do |j|
      	@positions[PLANETS[j]] = i if (tpos[j] / 1800 == i)
      end
    end
    return @positions
  end

end
