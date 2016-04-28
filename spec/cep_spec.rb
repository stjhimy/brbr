require 'spec_helper'
require 'fakeweb'

require 'net/http'

INVALID_ZIPS = [0, '0', '00', '000', '0000', '00000', '000000', '0000000', '4006000'].freeze
VALID_ZIPS = [22_640_100, '22640100', '22640100', '22640100', '22640100'].freeze
VALID_ZIPS_WITH_ZERO_AT_BEGINNING = ['05145100', '05145-100', '05.145-100'].freeze

URL = CEP::WEB_SERVICE_REPUBLICA_VIRTUAL_URL

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
      body = '&resultado=1&resultado_txt=sucesso+-+cep+completo&uf=RJ&cidade=Rio+de+Janeiro&bairro=Barra+da+Tijuca&tipo_logradouro=Avenida&logradouro=das+Am%E9ricas'

      FakeWeb.register_uri(:get, "#{URL}#{cep}", body: body)

      expect(expected).to eq CEP.busca(valid_zip)
    end
  end

  VALID_ZIPS_WITH_ZERO_AT_BEGINNING.each do |valid_zip|
    it "test_valid_code_#{valid_zip}" do
      cep = VALID_ZIPS_WITH_ZERO_AT_BEGINNING.first
      expected = { tipo_logradouro: 'Avenida', logradouro: "Raimundo Pereira de Magalhães", bairro: 'Jardim Iris', cidade: "São Paulo", uf: 'SP', cep: cep }
      body = '&resultado=1&resultado_txt=sucesso+-+cep+completo&uf=SP&cidade=S%E3o+Paulo&bairro=Jardim+Iris&tipo_logradouro=Avenida&logradouro=Raimundo+Pereira+de+Magalh%E3es'

      FakeWeb.register_uri(:get, "#{URL}#{cep}", body: body)

      expect(expected).to eq CEP.busca(cep)
    end
  end

  it 'test_should_raise_exception_when_invalid_code' do
    cep = '12345678'
    body = '&resultado=0&resultado_txt=servi%E7o+indispon%EDvel%2Fcep+inv%E1lido&uf=&cidade=&bairro=&tipo_logradouro=&logradouro='

    FakeWeb.register_uri(:get, "#{URL}#{cep}", body: body)
    expect { CEP.busca(cep) }.to raise_error(RuntimeError, "CEP #{cep} não encontrado.")
  end
end
