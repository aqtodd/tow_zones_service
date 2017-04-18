class TowZonesAPI
 def initialize
    @uri = URI(Rails.configuration.x.tz.api_url + Rails.configuration.x.tz.api_path)
    @wanted_fields = [
        'startdate',
        'enddate',
        'starttime',
        'endtime',
        'datetimeentered',
        'updatedon',
        'address',
        'latitude',
        'longitude',
        'cnn',
        'permitnumber'
    ]
    @order_by = [ 'updatedon', 'DESC' ]
    @where = [
      '(', 'startdate', 'like', this_month_like, ')',
      'OR',
      '(', 'startdate', 'like', next_month_like, ')',
    ]
  end

  def get(limit)
    @uri.query = URI.encode_www_form({
      '$select' => @wanted_fields.join(','),
      '$where' => @where.join(' '),
      '$order' => @order_by.join(' '),
      '$limit' => limit
    })
    Net::HTTP.get(@uri)
  end

  def this_month_like
    Time.now.strftime('\'%m/%/%Y\'')
  end

  def next_month_like
    next_month = Time.now.month + 1 
    Time.now.strftime("\'0#{next_month}/%/%Y\'")
  end
end
