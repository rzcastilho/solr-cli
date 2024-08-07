defmodule SolrCli.HttpClient do
  @moduledoc false

  @middleware [
    Tesla.Middleware.JSON,
    {Tesla.Middleware.Headers, [{"content-type", "application/json"}]},
    {
      Tesla.Middleware.Retry,
      [
        delay: 500,
        max_retries: 3,
        max_delay: 5_000
      ]
    }
  ]

  def new(opts) do
    middleware =
      [
        {Tesla.Middleware.BaseUrl, opts[:base_url]}
      ] ++ @middleware

    Tesla.client(middleware)
  end

  def count(client, collection, query \\ "*:*") do
    Tesla.get(client, "#{collection}/select?q=#{query}&rows=0")
  end

  def update(client, collection, request) do
    Tesla.post(client, "#{collection}/update", request)
  end
end
