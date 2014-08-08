require 'spec_helper'

describe Puppet::Type.type(:f5_monitor).provider(:tcp_half) do
  let(:resource) do
    Puppet::Type.type(:f5_monitor).new(
      name:               '/Common/tcp_half_closed',
      ensure:             :present,
      alias_address:      '10.0.0.1',
      alias_service_port: '23',
      description:        'tcphalftest',
      interval:           '5',
      manual_resume:      'disabled',
      time_until_up:      '5',
      timeout:            '16',
      transparent:        'disabled',
      up_interval:        '5',
      provider:           described_class.name
    )
  end
  let(:provider) { resource.provider }

  before :each do
    allow(Facter).to receive(:value).with(:url).and_return('https://admin:admin@bigip')
    allow(Facter).to receive(:value).with(:feature)
  end

  describe 'instances' do
    it 'gets a response from the api' do
      result = nil
      VCR.use_cassette('f5_monitor/tcp_half/instances') do
        result = provider.class.instances
      end
      expect(result.count).to eq(1)
    end
  end

  describe 'create' do
    it 'gets a response from the api' do
      result = nil
      VCR.use_cassette('f5_monitor/tcp_half/create') do
        result = provider.create
        provider.flush
      end
      expect(result.status).to eq(200)
    end
  end

  describe 'flush' do
    it 'gets a response from the api' do
      result = nil
      VCR.use_cassette('f5_monitor/tcp_half/flush') do
        provider.class.prefetch({ '/Common/tcphalf' => resource})
        provider.transparent= 'enabled'
        result = provider.flush
      end
      expect(result.status).to eq(200)
    end
  end

  describe 'destroy' do
    it 'gets a response from the api' do
      result = nil
      VCR.use_cassette('f5_monitor/tcp_half/destroy') do
        result = provider.destroy
        provider.flush
      end
      expect(result.status).to eq(200)
    end
  end
end
