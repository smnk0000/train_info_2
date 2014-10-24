require 'httpclient'
require 'json'
require 'sinatra'
require 'yaml'
require 'time'
require 'sinatra/reloader' if development?


# 定数定義
API_ENDPOINT   = 'https://api.tokyometroapp.jp/api/v2/'
DATAPOINTS_URL = API_ENDPOINT + 'datapoints'
ACCESS_TOKEN   = 'ccb3c5dd4262f57ef69827ab1b6e6b7dd2eb362d35807a4ebc0457fe13885db7'

# 路線リストの読み込み
RAILWAY_LIST   = YAML.load_file('railwayList.yaml')

def get_railways(railway_name)
  RAILWAY_LIST.each do |railway|
     return railway["odpt_line"] if railway_name == railway["line"]
  end
end


get "/" do

  @results = []
  
  RAILWAY_LIST.each do |railway|
    @results << {"line" => railway["line"]}
  end

  erb :index
end


post "/train_info" do

  @results = []
  
  http_client = HTTPClient.new
  response = http_client.get DATAPOINTS_URL,
                             {
                                 'rdf:type' => 'odpt:TrainInformation',
                                 'acl:consumerKey' => ACCESS_TOKEN,
                                 'odpt:railway' => get_railways(params[:TrainInformation])
                             }

  JSON.parse(response.body).each do |res|
    @results << {"railway" => params[:TrainInformation],
                 "message" => res["odpt:trainInformationText"],
                 "date"    => (Time.iso8601(res["dc:date"]) + 9*60*60).strftime("%Y-%m-%d %H:%M:%S")}
  end
  
  erb :train_info

end
