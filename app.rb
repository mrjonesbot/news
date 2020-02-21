require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "8cce7274e1f85a1faa1553e47d98095c"
news = HTTParty.get("https://newsapi.org/v2/top-headlines?country=us&apiKey=51da86f30127472987330dc7a0a2da27").parsed_response.to_hash

get "/" do
  view "ask"
end

get "/news" do
    results = Geocoder.search(params["q"])
    lat_long = results.first.coordinates
    @forecast = ForecastIO.forecast(lat_long[0],lat_long[1]).to_hash
    @current_temperature = @forecast["currently"]["temperature"]
    @current_summary = @forecast["currently"]["summary"]

    @forecast_temperature = Array.new
    @forecast_summary = Array.new

    i = 0
    for day in @forecast["daily"]["data"] do
        @forecast_temperature[i] = day["temperatureHigh"]
        @forecast_summary[i] = day["summary"]
        i = i+1
    end

    @source_name = Array.new
    @title = Array.new
    @description = Array.new
    @story_url = Array.new
    a = 0
    for story in news["articles"] do
        @source_name[a] = story["source"]["name"]
        @title[a] = story["title"]
        @description[a] = story["description"]
        @story_url[a] = story["url"]
        a = a+1
    end
    
    view "ask"

end
