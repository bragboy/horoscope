# Equivalent Java methods overriden for Ruby
module Math
  def self.toRadians(angdeg)
  	angdeg / 180.0 * Math::PI
  end

  def self.toDegrees(angrad)
  	angrad * 180.0 / Math::PI
  end

  def self.java_mod(x,y)
  	return 0 if x == 0 && y != 0
  	return x%y if (x > 0 && y > 0) || (x<0 && y<0)
  	return x%y - y
  end
end