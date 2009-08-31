class Schedule
  include HTTParty
  base_uri 'http://services.tvrage.com'
  http_proxy AppConfig.proxy_addr, AppConfig.proxy_port
  format :xml
  
end