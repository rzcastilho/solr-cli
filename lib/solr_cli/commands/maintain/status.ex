defmodule SolrCli.Commands.Maintain.Status do
  use DoIt.Command,
    description: "Get collection backup/restore status"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:solr, :string, "Solr Alias URL - See config command")

  option(:prefix, :string, "Request ID prefix")
  option(:reference, :string, "Solr Alias URL collections reference")
  option(:collections, :string, "Collection list separated by comma (,)")

  def run(_args, %{collections: _collections, reference: _reference}, context) do
    IO.puts("Only one option must be informed between --reference and --collections")
    help(context)
  end

  def run(%{solr: solr}, %{prefix: prefix, reference: reference}, %{config: %{"url" => urls}}) do
    solr_client = HttpClient.new(base_url: urls[solr])
    solr_reference = HttpClient.new(base_url: urls[reference])
    collections = Controller.collections(solr_reference)
    do_run(solr_client, collections, prefix)
  end

  def run(%{solr: solr}, %{prefix: prefix, collections: c9s}, %{config: %{"url" => urls}}) do
    solr_client = HttpClient.new(base_url: urls[solr])
    collections = String.split(c9s, ",")
    do_run(solr_client, collections, prefix)
  end

  def run(_args, _opts, context) do
    IO.puts("Please, inform --reference or --collections option")
    help(context)
  end

  defp do_run(solr_client, collections, prefix) do
    collections
    |> Stream.map(&"#{prefix}_#{&1}")
    |> Task.async_stream(&Controller.request_status(solr_client, &1), timeout: 15_000)
    |> Stream.run()
  end
end
