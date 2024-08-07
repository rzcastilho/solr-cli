defmodule SolrCli.Commands.Collections.Delete do
  use DoIt.Command,
    description: "Delete documents from a Solr collection"

  alias SolrCli.HttpClient

  argument(:solr, :string, "Solr")
  argument(:collection, :string, "Collection")

  option(:query, :string, "Solr query", default: "*:*")

  def run(
        %{solr: solr, collection: col},
        %{query: query},
        %{config: %{"url" => urls}}
      ) do
    cli = HttpClient.new(base_url: urls[solr])
    {:ok, %{body: %{"response" => %{"numFound" => count}}}} = HttpClient.count(cli, col, query)
    delete_documents(cli, col, query, count)
  end

  defp delete_documents(_cli, col, query, 0),
    do: IO.puts("Documents not found in the '#{col}' collection using query '#{query}'")

  defp delete_documents(cli, col, query, count) do
    answer =
      IO.gets("#{count} documents found! Proceed to deletion? (y/N) ")
      |> String.trim()
      |> String.downcase()

    case answer do
      "y" ->
        IO.write("Deletting documents... ")
        request = Jason.encode!(%{delete: %{query: query}})

        case HttpClient.update(cli, col, request) do
          {:ok, %{status: 200}} ->
            IO.puts("done!")

          {:ok, %{body: error}} ->
            IO.puts("HTTP Error >>>")
            IO.puts(Jason.encode!(error, pretty: true))

          {:error, error} ->
            IO.puts("Connection Error >>>")
            IO.puts(Jason.encode!(error, pretty: true))
        end

      _ ->
        IO.puts("Aborted!!!")
    end
  end
end
