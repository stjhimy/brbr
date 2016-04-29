require 'spec_helper'
require 'fakeweb'

require 'net/http'

INVALID_ZIPS = [0, '0', '00', '000', '0000', '00000', '000000', '0000000', '4006000'].freeze
VALID_ZIPS = [22_640_100, '22640100', '22640100', '22640100', '22640100'].freeze
VALID_ZIPS_WITH_ZERO_AT_BEGINNING = ['05145100', '05145-100', '05.145-100'].freeze

URL = CEP::WEBSERVICE_URL

describe CEP do
  it 'test_raise_without_service_on_both_web_services' do
    FakeWeb.register_uri(:get, "#{URL}22640100", status: 504, body: 'Service Unavailable')
    expect { CEP.busca(22_640_100) }.to raise_error RuntimeError
  end

  INVALID_ZIPS.each do |invalid_zip|
    it "test_raise_for_invalid_zip_code_#{invalid_zip}" do
      expect { CEP.busca(invalid_zip) }.to raise_error(RuntimeError, 'O CEP informado possui um formato inválido.')
    end
  end

  VALID_ZIPS.each do |valid_zip|
    it "test_valid_code_#{valid_zip}" do
      cep = valid_zip
      expected = { tipo_logradouro: 'Avenida', logradouro: 'das Américas', bairro: 'Barra da Tijuca', cidade: 'Rio de Janeiro', uf: 'RJ', cep: cep.to_s }
      body = expected.to_json

      FakeWeb.register_uri(:get, "#{URL}#{cep}", body: body)

      expect(body).to eq CEP.busca(valid_zip).to_json
    end
  end

  VALID_ZIPS_WITH_ZERO_AT_BEGINNING.each do |valid_zip|
    it "test_valid_code_#{valid_zip}" do
      cep = VALID_ZIPS_WITH_ZERO_AT_BEGINNING.first
      expected = { tipo_logradouro: 'Avenida', logradouro: "Raimundo Pereira de Magalhães", bairro: 'Jardim Iris', cidade: "São Paulo", uf: 'SP', cep: cep }
      body = expected.to_json

      FakeWeb.register_uri(:get, "#{URL}#{cep}", body: body)

      expect(body).to eq CEP.busca(cep).to_json
    end
  end
end
