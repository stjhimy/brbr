require 'net/http'
require 'cgi'
require 'json'

class CEP
  WEBSERVICE_URL = 'http://cep.republicavirtual.com.br/web_cep.php?formato=json&cep='.freeze

  #  CEP.busca(22640100) ==>
  #  {:tipo_logradouro => 'Avenida', :logradouro => 'das Américas', :bairro => 'Barra da Tijuca', :uf => 'RJ', :cidade => 'Rio de Janeiro', :cep => '22640100'}
  def self.busca(numero)
    cep = numero.to_s.gsub(/[\.-]/, '')
    raise "O CEP informado possui um formato inválido." unless cep.to_s =~ /^\d{8}$/

    response = Net::HTTP.get_response(URI.parse("#{WEBSERVICE_URL}#{cep}"))
    raise "A busca de endereço por CEP através do web service da República Virtual está indisponível." unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body).merge('cep' => cep)
  end
end
