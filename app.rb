require "sinatra"
require "sinatra/reloader"
require "http"
require "openai"

get("/") do
  erb(:homepage)
end

get("/character/new") do
  erb(:character_new)
end

get("/prompt/:char") do
  $character = params.fetch(:char)
  erb(:prompt_new)
end

get("/results") do
  client = OpenAI::Client.new(access_token: ENV.fetch("RENDER_GPT_API_KEY"))

  char_to_str = $character.gsub("+"," ")
  # Prepare an array of messages
  messages = [
    { "role" => "system", "content" => "You are roleplaying #{$character}. Always start your response with a greeting, while NEVER ending with a question. Fully embody the character's persona and respond accordingly. Be extra sure to utilize and emphasize the character's language." },
    { "role" => "user", "content" => "#{params.fetch("prompt_text")}" },
  ]

  # Print the parameters to debug
  # puts "Parameters: #{parameters}"

  # Call the API to get the next message from GPT

  @raw_api_response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo-0125",
      messages: messages,
    },
  )
  
  @response_fetch = @raw_api_response.dig("choices")[0].dig("message").dig("content")

  erb(:results)
end
