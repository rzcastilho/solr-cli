defmodule SolrCli.Commands.Collections.Status do
  use DoIt.Command,
    description: "Get collection status"

  alias SolrCli.HttpClient
  alias SolrCli.Controller
  alias TableRex.Table

  @headers ["Collection", "Shard", "Status", "Replica", "Status", "Node"]

  argument(:solr, :string, "Solr Alias URL - See config command")

  option(:collections, :string, "Collection list separated by comma (,)")

  def run(%{solr: solr}, %{collections: c9s}, %{config: %{"url" => urls}}) do
    solr_client = HttpClient.new(base_url: urls[solr])
    filter = String.split(c9s, ",")
    do_run(solr_client, filter)
  end

  def run(%{solr: solr}, _opts, %{config: %{"url" => urls}}) do
    solr_client = HttpClient.new(base_url: urls[solr])
    do_run(solr_client, [])
  end

  defp do_run(solr_client, filter) do
    {collections, _} = Controller.cluster_status(solr_client)

    rows =
      collections
      |> Enum.flat_map(fn %{name: coll, shards: shards} ->
        shards
        |> Enum.flat_map(fn %{name: shard, state: shard_state, replicas: replicas} ->
          replicas
          |> Enum.map(fn %{name: replica, state: replica_state, node_name: node_name} ->
            [coll, shard, shard_state, replica, replica_state, node_name]
          end)
        end)
      end)
      |> Enum.filter(fn [collection | _] ->
        case filter do
          [] -> true
          filter -> Enum.find(filter, fn coll -> coll == collection end)
        end
      end)

    Table.new(rows, @headers)
    |> Table.render!()
    |> IO.puts()
  end
end
