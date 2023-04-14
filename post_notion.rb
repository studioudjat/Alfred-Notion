require "net/http"
require "uri"
require "json"

NOTION_TOKEN = ENV["TOKEN"]
DATABASE_ID = ENV["DATABASE_ID"]

def post_notion(title, category)
  if category
    cat = "仕事"
  else
    cat = "プライベート"
  end
  uri = URI.parse("https://api.notion.com/v1/pages")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authorization"] = "Bearer #{NOTION_TOKEN}"
  request["Notion-Version"] = "2022-06-28"
  request.body =
    JSON.dump(
      {
        "parent" => {
          "database_id" => "#{DATABASE_ID}"
        },
        "properties" => {
          # Replace Name with your title name
          "Name" => {
            "title" => [{ "text" => { "content" => "#{title}" } }]
          },
          # Comment out or replace this property with your prefered property
          "Category" => {
            "select" => {
              "name" => "#{cat}"
            }
          }
        }
      }
    )

  response =
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

  code = response.code

  # Print error message if the response code is not 200
  STDERR.print "Error!\n#{response.body}\n" unless code == "200"
end

post_notion(ARGV[0], ARGV[1])
