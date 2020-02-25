require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
require 'news-api'
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key
ForecastIO.api_key = "f2b18bf011014e29a217c99dae3841a4"

# enter your News API key here
newsapi = News.new("7f7a3338481f4a0ea8d7b067e2b0ed0d")

get "/" do
    view "ask"
  # show a view that asks for the location
end

get "/news" do
    @location = params["location"]
    # puts @location
    geocode = Geocoder.search(@location)
    # puts geocode
    lat_long = geocode.first.coordinates # => [lat, long]
    lat = lat_long[0]
    long = lat_long[1]
    @lat_long = "#{lat_long[0]} #{lat_long[1]}"
    @forecast = ForecastIO.forecast(lat,long).to_hash
    
    
    current_temperature = @forecast["currently"]["temperature"]
    conditions = @forecast["currently"]["summary"]
    @current = "It is currently #{current_temperature} degrees and #{conditions}"
    location = @forecast["location"]

    @daily_forecast = @forecast["daily"]["data"]


    url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=7f7a3338481f4a0ea8d7b067e2b0ed0d"
    @news = HTTParty.get(url).parsed_response.to_hash
    @article = @news["articles"]

  view "news"
end