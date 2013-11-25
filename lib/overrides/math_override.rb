# Equivalent Java methods overriden for Ruby
module Math
  def self.IEEEremainder(x, y)
  	begin
	  regularMod = Math.java_mod(x,y) #DO NOT use Ruby Mod operator here as -1%13 yields different results for Java and Ruby
      return 0.0 if (regularMod == 0) 
      alternativeResult = regularMod - (y.abs * Math.signum(x))
      if alternativeResult.abs == regularMod.abs
        divisionResult = x/y
        roundedResult = divisionResult.round
        return roundedResult.abs > divisionResult.abs ? alternativeResult : regularMod
      end
      return alternativeResult.abs < regularMod.abs ? alternativeResult : regularMod
  	rescue ZeroDivisionError
  	  return 0.0/0.0 #NaN
  	end
  end

  def self.toRadians(angdeg)
  	angdeg / 180.0 * Math::PI
  end

  def self.toDegrees(angrad)
  	angrad * 180.0 / Math::PI
  end

  def self.signum(num)
    num > 0 ? 1 : (num == 0? 0 : -1)
  end

  def self.java_mod(x,y)
  	return 0 if x == 0 && y != 0
  	return x%y if (x > 0 && y > 0) || (x<0 && y<0)
  	return x%y - y
  end
end