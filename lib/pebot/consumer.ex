defmodule Pebot.Consumer do

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
      Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
      cond do
        msg.content == "!oi" -> Api.create_message(msg.channel_id, "olá")


        String.starts_with?(msg.content, "!tempo") -> handleWeather(msg)
        msg.content == "!tempo" -> Api.create_message(msg.channel_id, "Use !tempo <nomedacidade> para pesquisar a temperatura da cidade.")

        String.starts_with?(msg.content, "!cat") -> handleCatImage(msg)

        String.starts_with?(msg.content, "!fish") -> handleFish(msg)
        msg.content == "!fish" -> Api.create_message(msg.channel_id, "Use !fish <nomedopeixe> para pesquisar a espécie do peixe pesquisado.")

        String.starts_with?(msg.content, "!name") -> handleName(msg)
        msg.content == "!name" -> Api.create_message(msg.channel_id, "Use !name <nome> para pesquisar informações sobre o nome.")

        String.starts_with?(msg.content, "!cep") -> handleCEP(msg)
        msg.content == "!cep" -> Api.create_message(msg.channel_id, "Use !cep <cep> para pesquisar informações sobre o cep digitado.")

        String.starts_with?(msg.content, "!fruit") -> handleFruit(msg)
        msg.content == "!fruit" -> Api.create_message(msg.channel_id, "Use !fruit <nomedafruta> para pesquisar informações sobre a fruta.")

        String.starts_with?(msg.content, "!strthings") -> handleStrThings(msg)
        msg.content == "!strthings" -> Api.create_message(msg.channel_id, "Use !strthings <numero> para procurar frases faladas pelos personagens da série.")

        String.starts_with?(msg.content, "!password") -> handlePassword(msg)

        String.starts_with?(msg.content, "!webseries") -> handleWebSeries(msg)

        String.starts_with?(msg.content, "!spaceX") -> handleSpaceX(msg)

        String.starts_with?(msg.content, "!cidade") -> handleCidade(msg)
        msg.content == "!cidade" -> Api.create_message(msg.channel_id, "Use !cidade <nomedacidade> para pesquisar informações sobre a cidade.")

        String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido tente novamente")

        true -> :ignore
      end
  end

  defp handleWeather(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    cidade = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=aeda6cd58ea196b80577ec7bb4ebb60d&units=metric&lang=pt_br")

    {:ok, map} = Poison.decode(resp.body)

    case map["cod"] do

      200 ->
        temp = map["main"]["temp"]
        Api.create_message(msg.channel_id, "A temperatura de #{cidade} é de #{temp} grau celsius")

      "404" ->
        Api.create_message(msg.channel_id, "Comando inválido")

    end

  end

  defp handleCatImage(msg) do

    resp = HTTPoison.get!("https://api.thecatapi.com/v1/images/search")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Api.create_message(msg.channel_id, "#{x["url"]}") end)

  end

  defp handleFish(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    fish = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://www.fishwatch.gov/api/species/#{fish}")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Api.create_message(msg.channel_id, "#{x["Scientific Name"]}") end)

  end

  defp handleName(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    nome = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://servicodados.ibge.gov.br/api/v2/censos/nomes/#{nome}")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Enum.each(x["res"], fn y -> Api.create_message(msg.channel_id, "No período de #{y["periodo"]} existia #{y["frequencia"]} pessoas com o nome #{nome}") end) end)

  end

  defp handleCEP(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    cep = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://brasilapi.com.br/api/cep/v1/#{cep}")

    {:ok, map} = Poison.decode(resp.body)

    cidade = map["city"]
    rua = map["street"]
    Api.create_message(msg.channel_id, "A cidade do cep #{cep} é #{cidade} e a sua rua é #{rua} ")

  end

  defp handleFruit(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    fruit = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://www.fruityvice.com/api/fruit/#{fruit}")

    {:ok, map} = Poison.decode(resp.body)

    carbo = map["nutritions"]["carbohydrates"]
    proteina = map["nutritions"]["protein"]
    calorias = map["nutritions"]["calories"]

    Api.create_message(msg.channel_id, "A fruta #{fruit} tem #{carbo} carboidratos, #{proteina} de proteína e tem #{calorias} calorias.")

  end

  defp handleStrThings(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    number = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://strangerthings-quotes.vercel.app/api/quotes/#{number}")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Api.create_message(msg.channel_id, "#{x["author"]}: #{x["quote"]}") end)

  end

  defp handlePassword(msg) do
    # aux = String.split(msg.content, " ", parts: 2)
    # number = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://passwordinator.herokuapp.com")

    {:ok, map} = Poison.decode(resp.body)

    data = map["data"]

    Api.create_message(msg.channel_id, "Sua senha é: #{data}")

  end

  defp handleWebSeries(msg) do
    # aux = String.split(msg.content, " ", parts: 2)
    # number = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://web-series-quotes-api.deta.dev/series")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Api.create_message(msg.channel_id, "Séries disponíveis: #{x}") end)

  end

  defp handleSpaceX(msg) do
    # aux = String.split(msg.content, " ", parts: 2)
    # number = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://api.spacexdata.com/v4/launches/latest")

    {:ok, map} = Poison.decode(resp.body)

    video = map["links"]["webcast"]
    name = map["name"]

    Api.create_message(msg.channel_id, "Missão da SpaceX:
    Nome: #{name}
    Vídeo: #{video}")

  end

  defp handleCidade(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    cidade = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://www.metaweather.com/api/location/search/?query=#{cidade}")

    {:ok, map} = Poison.decode(resp.body)

    Enum.each(map, fn x -> Api.create_message(msg.channel_id, "Cidade: #{x["title"]}
Latitude e Longitude: #{x["latt_long"]}") end)

  end

  def handle_event(_event) do
      :noop
  end

end
