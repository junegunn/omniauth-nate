require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test/unit'
require 'mocha'
require 'omniauth-nate'
require 'rack/test'
require 'webmock'

class OmniauthNateTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include WebMock::API

  def setup
    @consumer_key = 'consumer key'
    @consumer_secret = 'consumer secret'

    @iv = 0.chr * 8
    @key = 'encryption key for triple des'
    @algorithm = 'des-ede3-cbc'

    @email = "you@and.me"
    @name = "yam"
  end

  # Borrowed from omniauth-oauth spec
  def app
    Rack::Builder.new {
      use OmniAuth::Test::PhonySession
      use OmniAuth::Builder do
        provider :nate, 'consumer key', 'consumer secret',
          :encryption => { :key => 'encryption key for triple des' }
      end
      run lambda { |env| [404, {'Content-Type' => 'text/plain'}, [env.key?('omniauth.auth').to_s]] }
    }.to_app
  end

  def session
    last_request.env['rack.session']
  end

  def encrypt str
    c = OpenSSL::Cipher.new(@algorithm)
    c.encrypt
    c.key = @key
    c.iv = @iv
    text = c.update(str)
    text << c.final
    Base64.encode64 text
  end

  def decrypt str
    c = OpenSSL::Cipher.new(@algorithm)
    c.decrypt
    c.key = @key
    c.iv = @iv
    text = c.update(Base64.decode64 str)
    text << c.final
    text
  end

  def test_encrypt_decrypt
    str = "Meta-test: Testing encryption and decryption methods used in the test"
    assert_equal str, decrypt(encrypt(str))
  end

  def test_encryption_key_is_required
    assert_raise(ArgumentError) do
      nate = OmniAuth::Strategies::Nate.new(nil, @consumer_key, @consumer_secret)
    end
  end

  def test_encryption_parameters
    nate = OmniAuth::Strategies::Nate.new(nil, @consumer_key, @consumer_secret, 
                :encryption => { 
                  :key => @key,
                  :iv => @iv,
                  :algorithm => 'des3'
                })
    assert_equal @key,   nate.encryption[:key]
    assert_equal @iv,    nate.encryption[:iv]
    assert_equal 'des3', nate.encryption[:algorithm]
  end

  def test_name
    nate = OmniAuth::Strategies::Nate.new(nil, @consumer_key, @consumer_secret, 
                :encryption => { :key => @key })
    assert_equal 'nate', nate.name
  end

  def test_request
    stub_request(:post, "https://oauth.nate.com/OAuth/GetRequestToken/V1a").
        to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret&oauth_callback_confirmed=true")
    get "/auth/nate"

    assert last_response.redirect?
    assert_equal 'https://oauth.nate.com/OAuth/Authorize/V1a?oauth_token=yourtoken',
                  last_response.headers['Location'].to_s
    assert_equal 'yourtoken', session['oauth']['nate']['request_token']
    assert_equal 'yoursecret', session['oauth']['nate']['request_secret']

    assert_requested :post, 'https://oauth.nate.com/OAuth/GetRequestToken/V1a'

    stub_request(:post, "https://oauth.nate.com/OAuth/GetAccessToken/V1a").
        to_return(:body => "oauth_token=yourtoken&oauth_token_secret=yoursecret")

    stub_request(:get, "https://oauth.nate.com/OAuth/GetNateMemberInfo/V1a").
        to_return(:body => "<response><rcode>RET0000</rcode><rmsg>SUCCESS</rmsg><class>1</class><minfo><nid>#{encrypt @email}</nid><name>#{encrypt @name}</name></minfo></response>")

    get '/auth/nate/callback', { :oauth_verifier => 'verifier' }
    assert_requested :post, 'https://oauth.nate.com/OAuth/GetAccessToken/V1a'
    assert_requested :get, 'https://oauth.nate.com/OAuth/GetNateMemberInfo/V1a'

    assert_equal 'true', last_response.body
    assert_equal @email, last_request.env['omniauth.auth']['uid']
    assert_equal @email, last_request.env['omniauth.auth']['info']['email']
    assert_equal @name,  last_request.env['omniauth.auth']['info']['name']
  end

  def test_basic
    nate = OmniAuth::Strategies::Nate.new(nil, @consumer_key, @consumer_secret, :encryption => { :key => @key })
  end
end

