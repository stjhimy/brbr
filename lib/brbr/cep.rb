require 'net/http'
require 'cgi'
require 'json'

# Doc
class CEP
  WEBSERVICE_URL = 'http://cep.republicavirtual.com.br/web_cep.php?formato=json&cep='.freeze

  def self.busca(numero)
    cep = numero.to_s.gsub(/[\.-]/, '')

    unless cep.to_s =~ /^\d{8}$/
      raise "O CEP informado possui um formato inválido."
    end

    response = Net::HTTP.get_response(URI.parse("#{WEBSERVICE_URL}#{cep}"))

    unless response.is_a?(Net::HTTPSuccess)
      raise "A busca de endereço por CEP através do web service da República Virtual está indisponível."
    end

    JSON.parse(response.body).merge('cep' => cep)
  end
end
