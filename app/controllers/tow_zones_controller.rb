require 'time'
STRPSTRING = "%m/%d/%Y%H:%M"

class TowZonesController < ApplicationController
  before_action :validate_channel_key
  before_action :validate_params, only: :index

  def initialize
    @channel_key = Rails.application.secrets.ifttt_channel_key
    @tow_zones = TowZonesAPI.new
  end

  def status
    head :ok
  end

  def setup
    render json: { data: { samples: { triggers: { tow_zones: {
              address: {
                valid: "701 Scott St, San Francisco, CA",
                invalid: "701 Scott St"
              }
    } } } } }
  end

  def index
    limit = (request.params['limit'] || 50).to_i
    parking_data = fetch_data(limit * 2)
    parking_data.map! {|item| format(item) }
    parking_data.uniq! {|item| item[:meta][:id] }
    render json: { data: parking_data.first(limit) }
  end

  private

  def validate_channel_key
    unless request.headers['HTTP_IFTTT_CHANNEL_KEY'] == @channel_key
      return render json: { errors: [ { message: "Missing or incorrect channel key. Unauthorized." } ] }, status: 401
    end
  end

  def validate_params
    if request.params['triggerFields'].nil? or not request.params['triggerFields'].include?('address')
      return render json: { errors: [ {"message": "Missing one or more required trigger fields." } ] }, status: 400
    end
  end

  def fetch_data(limit)
    JSON.parse(@tow_zones.get(limit))
  end

  def md5(args_array)
    args_string = ''
    args_array.each {|arg| args_string = args_string + arg.to_s }
    Digest::MD5.base64digest args_string
  end

  def format(item)
    {
      start_date: item['startdate'],
      end_date: item['enddate'],
      start_time: item['starttime'],
      end_time: item['endtime'],
      address: item['address'],
      location: {
        lat: item['latitude'],
        long: item['longitude']
      },
      meta: {
        id: md5([item['permitnumber'], item['cnn'], item['address'], item['updatedon']]),
        timestamp: item['updatedon'].to_time.utc.to_i
      },
      created_at: item['datetimeentered'].to_time.utc.iso8601
    }
  end
end
