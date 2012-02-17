require 'goliath'
require 'em-synchrony/em-http'
require 'digest/sha1'

# Config vars

CONSUMER_KEY = '3s01qXLnUxyfDxg0xlpXA'
CONSUMER_SECRET = '27PzjAK0ClxsavLMghvuMS5ieQsbujGs52EaaA3k0'

# Step1: Super-simple twitter login

class Test < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validations::RequiredParam, key: 'd'

  def response(env)
    data = params['d']
  end
end

class GoliExp < Goliath::API
  post '/test', Test
end
