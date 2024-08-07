defmodule SolrCli.Commands.Config.Delete do
  use DoIt.Command,
    description: "Delete Solr collections"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:solr, :string, "Solr")

  def run(
        %{
          solr: solr
        },
        _options,
        %{config: %{"url" => urls}}
      ) do
    start = DateTime.utc_now()
    solr_client = HttpClient.new(base_url: urls[solr])

    IO.puts(
      "#{DateTime.to_iso8601(DateTime.utc_now())} - Fetching configuration from Solr #{urls[solr]}..."
    )

    solr_client
    |> Controller.collections()
    |> Enum.map(&"/admin/collections?action=DELETE&name=#{&1}")
    # |> Enum.filter(fn uri -> !Enum.any?(["/userData_520_new/", "/userData_521/", "/userData_940/"], &String.contains?(uri, &1)) end)
    |> Enum.each(&Controller.request(solr_client, &1))

    # |> Enum.each(&IO.puts/1)

    finish = DateTime.utc_now()
    IO.puts("\n#{DateTime.to_iso8601(finish)} - Done! (#{DateTime.diff(finish, start)}s)")
  end
end
