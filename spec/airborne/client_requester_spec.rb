require 'spec_helper'

describe 'client requester' do
  before do
    allow(RestClient).to receive(:send)
    RSpec::Mocks.space.proxy_for(self).remove_stub_if_present(:get)
  end

  after do
    allow(RestClient).to receive(:send).and_call_original
    Airborne.configure { |config| config.headers = {} }
  end

  it 'should set :content_type to :json by default' do
    get '/foo', user_agent: 'test'

    expect(RestClient).to have_received(:send)
      .with(:get,
            'http://www.example.com/foo',
            content_type: :json,
            user_agent: 'test')
  end

  it 'should override headers with option[:headers]' do
    get '/foo',
        content_type: 'application/x-www-form-urlencoded',
        user_agent: 'test'

    expect(RestClient).to have_received(:send)
      .with(:get,
            'http://www.example.com/foo',
            content_type: 'application/x-www-form-urlencoded',
            user_agent: 'test')
  end

  it 'should override headers with airborne config headers' do
    Airborne.configure { |config| config.headers = { content_type: 'text/plain', user_agent: 'test' } }

    get '/foo'

    expect(RestClient).to have_received(:send)
      .with(:get,
            'http://www.example.com/foo',
            content_type: 'text/plain',
            user_agent: 'test')
  end

  it 'should have a specific user agent header' do
    RSpec::Matchers.define :a_user_agent_header do
      match do |actual|
        actual[:user_agent] =~ %r{airborne\/([0-9\.]+)\ rest-client\/([0-9a-z\.]+)\ (.*)\ ([a-z]+)\/([a-z0-9\.]+)}
      end
    end

    get '/foo'
    expect(RestClient).to have_received(:send)
      .with(:get, 'http://www.example.com/foo', a_user_agent_header)
  end
end
