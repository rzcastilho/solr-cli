defmodule SolrCli.Commands.Collections.Compare do
  use DoIt.Command,
    description: "Compare collections total documents between Solr's"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:solr_source, :string, "Solr source reference")
  argument(:solr_target, :string, "Solr restore target")

  def run(
        %{
          solr_source: solr_source,
          solr_target: solr_target
        },
        _options,
        %{config: %{"url" => urls}}
      ) do
    start = DateTime.utc_now()
    solr_source_client = HttpClient.new(base_url: urls[solr_source])
    solr_target_client = HttpClient.new(base_url: urls[solr_target])

    IO.puts(
      "#{DateTime.to_iso8601(DateTime.utc_now())} - Fetching configuration from Solr #{urls[solr_source]}..."
    )

    solr_source_client
    |> Controller.collections()
    # |> Enum.map(& "/admin/collections?action=RESTORE&name=#{&1}#{suffix}&repository=#{repository}&location=#{location}&collection=#{&1}&async=#{timestamp}_#{&1}")
    # |> Enum.filter(fn uri -> !Enum.any?(["/userData_520_new/", "/userData_521/", "/userData_940/"], &String.contains?(uri, &1)) end)
    |> Enum.each(&HttpClient.count(solr_target_client, &1))

    # |> Enum.each(&IO.puts/1)

    finish = DateTime.utc_now()
    IO.puts("\n#{DateTime.to_iso8601(finish)} - Done! (#{DateTime.diff(finish, start)}s)")
  end
end
