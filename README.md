# Horoscope

Calculate the accurate horoscope of a person using Vedic Horoscope technique given the birth time and birth place of the subject. The gem is available at https://rubygems.org/gems/horoscope

[![Travis CI   ](https://api.travis-ci.org/bragboy/horoscope.png)     ](https://travis-ci.org/bragboy/horoscope)
[![Code Climate](https://codeclimate.com/github/bragboy/horoscope.png)](https://codeclimate.com/github/bragboy/horoscope)
[![Gemnasium   ](https://gemnasium.com/bragboy/horoscope.png)           ](https://gemnasium.com/bragboy/horoscope)
[![Coveralls   ](https://coveralls.io/repos/bragboy/horoscope/badge.png)](https://coveralls.io/r/bragboy/horoscope)

## Installation

Add this line to your application's Gemfile:

    gem 'horoscope'
    
And then execute:

    $ bundle

Or install it yourself as:

    $ gem install horoscope
    
Then you can start using this by passing a Time object along with latitude and longitude
    
    #To calculate Sachin Tendulkar's horoscope
    h = Horoscope::Horo.new(
        :datetime => Time.utc(1973, 4, 24, 14, 25), 
        :zone => 5.5,
        :lat => 18.60, :lon => -72.50)
  	h.compute
  	 => {"As"=>4, "Su"=>0, "Mo"=>8, "Ma"=>9, "Me"=>11, "Ju"=>9, "Ve"=>0, "Sa"=>1, "Ra"=>8, "Ke"=>2}

  	h.create_chart #This will generate the horoscope chart to your working directory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Future Development

I am currently adding features to generate charts (both South and North Indian). Also show more data like Birth Star, Dasha Directions etc., Follow this page for more updates
