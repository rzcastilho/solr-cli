defmodule SolrCli.Commands.Maintain.Backup do
  use DoIt.Command,
    description: "Backup Solr collections"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:solr, :string, "Solr Alias URL - See store command")
  argument(:repository, :string, "Target repository")
  argument(:location, :string, "Location directory")

  option(:suffix, :string, "Backup suffix", default: "_bkp")
  option(:collections, :string, "Collection list separated by comma (,)")

  def run(
        %{solr: solr, repository: repository, location: location},
        %{suffix: suffix, collections: c9s},
        %{config: %{"url" => urls}}
      ) do
    solr_client = HttpClient.new(base_url: urls[solr])
    collections = String.split(c9s, ",")
    do_run(solr_client, repository, location, collections, suffix)
  end

  def run(%{solr: solr, repository: repository, location: location}, %{suffix: suffix}, %{
        config: %{"url" => urls}
      }) do
    solr_client = HttpClient.new(base_url: urls[solr])
    collections = Controller.collections(solr_client)
    do_run(solr_client, repository, location, collections, suffix)
  end

  defp do_run(solr_client, repository, location, collections, suffix) do
    timestamp =
      DateTime.utc_now()
      |> DateTime.to_unix()

    collections
    |> Stream.map(
      &"/admin/collections?action=BACKUP&name=#{&1}#{suffix}&repository=#{repository}&location=#{location}&collection=#{&1}&async=#{timestamp}_#{&1}"
    )
    |> Task.async_stream(&Controller.request(solr_client, &1), timeout: 30_000)
    |> Stream.run()
  end
end
