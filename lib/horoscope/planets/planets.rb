class Planet
  J2000 = 2451545.0
  ASC, SUN, MON, MAR, MER, JUP, VEN, SAT, RAH, KET = [0,1,2,3,4,5,6,7,8,9]

  def self.get_jul_day(month, day, year)
    im = 12 * (year + 4800) + month - 3
    july_day = (2 * (im % 12) + 7 + 365 * im) / 12
    july_day += day + im / 48 - 32083;
    july_day += (im / 4800 - im / 1200 + 38) if july_day > 2299171
    july_day
  end

  def self.get_terms(pp, num, t)
    v = 0.0
    (0..(num/3-1)).each do |i|
      a = pp[i * 3] * 1.0E-8
      b = pp[i * 3 + 1] * 1.0E-8
      c = pp[i * 3 + 2] * 0.001
      v += a * Math.cos(b + c * t)
    end
    v
  end

  def self.get_planet(t, pol, lrg, tlist, tnum)
    u = t/10.0
    (0..2).each do |i|
      tmp = 0.0
      pwr = 1.0
      (0..2).each do |j|
        tp = tlist[i*3 + j]
        n = tnum[i*3 + j]
        x = 0.0
        pwr *= u unless j == 0
        unless tp.empty?
          x = get_terms(tp, n, u)
          x += lrg[i * 3 + j]
          x *= pwr
        end
        tmp += x
      end
      pol[i] = tmp
    end
  end

  def self.hel2geo(pol, spol)
    l = pol[0]
    b = pol[1]
    r = pol[2]
    sunL = spol[0]
    sunB = spol[1]
    sunR = spol[2]
    x = r * Math.cos(b) * Math.cos(l) - sunR * Math.cos(sunB) * Math.cos(sunL)
    y = r * Math.cos(b) * Math.sin(l) - sunR * Math.cos(sunB) * Math.sin(sunL)
    lon = Math.atan2(y, x)
    lon += 6.283185307179586 if lon < 0.0
    lon
  end

  def self.get_lunar(t)
    t2 = t * t;
    l = 218.31665436 + 481267.8813424 * t - 0.0013268 * t2 + 1.856E-6 * (t * t2)
    d = 297.8502042 + 445267.11151675 * t - 0.00163 * t + 1.832E-6 * (t * t2)
    m = 357.52910918 + 35999.05029094 * t - 1.536E-4 * t2 + 4.1E-8 * (t * t2)
    mm = 134.96341138 + 477198.86763133 * t + 0.008997 * t2 + 1.4348E-5 * (t * t2)
    f = 93.2720993 + 483202.0175273 * t - 0.0034029 * t2 - 2.84E-7 * (t * t2)
    e = 1.0 - 0.002516 * t - 7.4E-6 * t2
    p = 0.0
    (0..(Planets::Moon::NLUNTERMS-1)).each do |i|
      term = Planets::Moon::TRG[i * 4] * d
      term += Planets::Moon::TRG[i * 4 + 1] * m
      term += Planets::Moon::TRG[i * 4 + 2] * mm
      term += Planets::Moon::TRG[i * 4 + 3] * f
      x = (Planets::Moon::TRG[i * 4 + 1]).abs
      y = Planets::Moon::TRM[i] * 1.0E-8
      unless x == 0
        e_temp = e
        e_temp = e * e if x == 2
        p += y * e_temp * Math.sin(Math.toRadians(term))
      else
        p += y * Math.sin(Math.toRadians(term))
      end
    end
    a1 = 119.75 + 131.849 * t
    a2 = 53.09 + 479264.29 * t
    p += 0.003958 * Math.sin(Math.toRadians(a1)) + 0.001926 * Math.sin(Math.toRadians(l - f)) + 3.18E-4 * Math.sin(Math.toRadians(a2))
    l += p
    l %= 360.0
  end

  def self.get_node(t, mean)
    lon = 0.0;
    n = 125.0446 - 1934.13618 * t + 0.0020762 * (t * t) + 2.139E-6 * (t * t * t)
    n += 1.65E-8 * (t * t * t * t)
    (0..21).each do |i|
      x = Planets::Nod::TERMS[i * 5 + 1] * 1.0E-4
      x += Planets::Nod::LRG[i] * t
      x += Planets::Nod::TERMS[i * 5 + 2] * 1.0E-7 * t * t
      x += Planets::Nod::TERMS[i * 5 + 3] * 1.0E-9 * t * t * t
      x += Planets::Nod::TERMS[i * 5 + 4] * 1.0E-11 * t * t * t * t
      lon += Planets::Nod::TERMS[i * 5] * 1.0E-4 * Math.sin(Math.toRadians(x))
    end
    phi = 125.0 - 1934.1 * t
    sm = 25.9 * Math.sin(Math.toRadians(phi))
    phi = 220.2 - 1935.5 * t
    sm += -4.3 * Math.sin(Math.toRadians(phi))
    ss = 0.38 * Math.sin(Math.toRadians(357.5 + 35999.1 * t))
    sm = Math.toDegrees(sm + ss * t)
    sm *= 1.0E-5
    lon += sm
    lon += n
    lon %= 360.0
    mn = n % 360.0
    mean[0] = mn
    lon
  end

  def self.get_ayan(t)
    ayan = (5029.0 + 1.11 * t) * t + 85886.0
    ayan /= 3600.0
    -ayan
  end

  def self.ascendant(t, tod, lg, lt)
    ra = (246.697374558 + 2400.0513 * t + tod) * 15.0 - lg
    ra %= 360.0
    ra = Math.toRadians(ra)
    ob = 23.439291 - 0.0130042 * t - 1.639E-7 * t * t
    ob = Math.toRadians(ob)
    as = Math.atan2(Math.cos(ra), -Math.sin(ra) * Math.cos(ob) - Math.tan(Math.toRadians(lt)) * Math.sin(ob))
    as += 3.141592653589793 if as < 0.0
    as += 3.141592653589793 if Math.cos(ra) < 0.0
    puts as
    return Math.toDegrees(as)
  end

  def self.range(lon)
    Math.toDegrees(lon) % 360.0
  end

  def self.planets(t, pos)
    pol = [0.0, 0.0, 0.0]
    spol = [0.0, 0.0, 0.0]
    pos[ASC] = 0

    get_planet(t, pol, Planets::Earth.lrg, Planets::Earth.ptr, Planets::Earth.terms)
    spol[0] = pol[0]
    spol[1] = pol[1]
    spol[2] = pol[2]
    lon = pol[0]
    lon %= 6.283185307179586
    u = t / 100.0
    a1 = 2.18 - 3375.7 * u + 0.36 * u * u
    a2 = 3.51 + 125666.39 * u + 0.1 * u * u
    nu = 1.0E-7 * (-834.0 * Math.sin(a1) - 64.0 * Math.sin(a2))
    ab = -993.0 + 17.0 * Math.cos(3.1 + 62830.14 * u)
    ab *= 1.0E-7
    lon += ab + nu
    lon = range(lon) + 180.0;
    lon -= 360.0 if lon > 360.0
    pos[SUN] = lon
    pos[MON] = get_lunar(t)

    get_planet(t, pol, Planets::Mercury.lrg, Planets::Mercury.ptr, Planets::Mercury.terms)
    lon = hel2geo(pol, spol)
    ab = -1261.0 + 1485.0 * Math.cos(2.649 + 198048.273 * u)
    ab += 305.0 * Math.cos(5.71 + 458927.03 * u)
    ab += 230.0 * Math.cos(5.3 + 396096.55 * u)
    ab *= 1.0E-7
    lon += ab + nu
    pos[MER] = range(lon);

    get_planet(t, pol, Planets::Venus.lrg, Planets::Venus.ptr, Planets::Venus.terms)
    lon = hel2geo(pol, spol)
    ab = -1304.0 + 1016.0 * Math.cos(1.423 + 39302.097 * u)
    ab += 224.0 * Math.cos(2.85 + 78604.19 * u)
    ab += 98.0 * Math.cos(4.27 + 117906.29 * u)
    ab *= 1.0E-7
    lon += ab + nu
    pos[VEN] = range(lon)

    get_planet(t, pol, Planets::Mars.lrg, Planets::Mars.ptr, Planets::Mars.terms)
    lon = hel2geo(pol, spol)
    ab = -1052.0 + 877.0 * Math.cos(1.834 + 29424.634 * u)
    ab += 187.0 * Math.cos(3.67 + 58849.27 * u)
    ab += 84.0 * Math.cos(3.49 + 33405.34 * u)
    ab *= 1.0E-7
    lon += ab + nu
    pos[MAR] = range(lon)

    get_planet(t, pol, Planets::Jupiter.lrg, Planets::Jupiter.ptr, Planets::Jupiter.terms)
    lon = hel2geo(pol, spol)
    ab = -527.0 + 978.0 * Math.cos(1.154 + 57533.849 * u)
    ab += 89.0 * Math.cos(2.3 + 115067.7 * u)
    ab += 46.0 * Math.cos(4.64 + 62830.76 * u)
    ab += 45.0 * Math.cos(0.76 + 52236.94 * u)
    ab *= 1.0E-7
    lon += ab
    lon += nu
    pos[JUP] = range(lon)

    get_planet(t, pol, Planets::Saturn.lrg, Planets::Saturn.ptr, Planets::Saturn.terms)
    lon = hel2geo(pol, spol)
    ab = -373.0 + 986.0 * Math.cos(0.88 + 60697.768 * u)
    ab += 54.0 * Math.cos(3.31 + 62830.76 * u)
    ab += 52.0 * Math.cos(1.59 + 58564.78 * u)
    ab += 51.0 * Math.cos(1.76 + 121395.54 * u)
    ab *= 1.0E-7
    lon += ab + nu
    pos[SAT] = range(lon)

    mnode = [0.0]
    lon = get_node(t, mnode)
    pos[RAH] = lon

    lon += 180.0
    lon -= 360.0 if lon > 360.0
    pos[KET] = lon
  end

  def self.get_planets(t, pps, sps)
    spd = Array.new(10, 0.0)
    planets(t, pps)
    hourbefore = t - 1.1407711613050422E-6
    planets(hourbefore, spd)
    (1..9).each do |i|
      spd[i] = pps[i] - spd[i]
      spd[i] -= 360.0 if spd[i] > 360.0
      spd[i] *= 24.0
      sps[i] = Math.java_mod(spd[i], 360.0)
      sps[i] += 360.0 if sps[i] > 0.0
    end
    spd[2] += 360.0 if spd[2] < 0.0
  end

end