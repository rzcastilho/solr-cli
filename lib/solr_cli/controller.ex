defmodule SolrCli.Controller do
  @moduledoc false

  import SolrCli.Helpers

  defmodule Search do
    defstruct [
      :client,
      :collection,
      :query,
      max: 10_000,
      rows: 10
    ]
  end

  alias Plug.Conn.Query
  alias SolrCli.Counter

  require Logger

  @ignore_fields ~w(
    _version_
    _text_
    _root_
    _nest_path_
   )

  def fetch_documents(%Search{
        client: client,
        collection: collection,
        query: query,
        max: max,
        rows: rows
      }) do
    case Tesla.get(client, "#{collection}/select?#{Query.encode(query)}&rows=0") do
      {:ok, %Tesla.Env{status: 200, body: %{"response" => %{"numFound" => total}}}} ->
        take =
          cond do
            total > max -> max
            true -> total
          end

        {:ok, counter} = Counter.start_link(take)

        0..take//String.to_integer("#{rows}")
        |> Task.async_stream(
          &Tesla.get(
            client,
            "#{collection}/select?#{Query.encode(query)}&start=#{&1}&rows=#{rows}&sort=idKey+asc"
          ),
          timeout: 60_000
        )
        |> Stream.flat_map(fn {:ok,
                               {:ok,
                                %Tesla.Env{status: 200, body: %{"response" => %{"docs" => docs}}}}} ->
          Counter.inc(counter, length(docs))
          {c, t} = Counter.info(counter)
          IO.write("\r * #{c}/#{t}")
          docs
        end)
        |> Stream.take(take)
    end
  end

  def reindex_documents(%Search{} = source, client_target, collection_target, mapper) do
    source
    |> fetch_documents()
    |> Stream.map(&apply_mapper(&1, mapper))
    |> Stream.map(&remove_fields/1)
    |> Stream.chunk_every(100)
    |> Task.async_stream(&Tesla.post(client_target, "#{collection_target}/update/json/docs", &1),
      timeout: :infinity,
      max_concurrency: 8
    )
    |> Stream.run()
  end

  def count(client, collection, query) do
    case Tesla.get(client, "#{collection}/select?#{Query.encode(query)}") do
      {:ok, %Tesla.Env{status: 200, body: %{"response" => %{"numFound" => count}}}} ->
        Logger.info("Query Count: #{count}")
        Map.put(query, :count, count)
    end
  end

  def cluster_status(client) do
    case Tesla.get(client, "/admin/collections?action=CLUSTERSTATUS") do
      {:ok, %{body: %{"cluster" => %{"collections" => collections, "aliases" => aliases}}}} ->
        {
          collections
          |> Enum.to_list()
          |> Enum.map(&collection_mapper/1),
          aliases
          |> Enum.to_list()
          |> Enum.map(&alias_mapper/1)
        }
    end
  end

  def collections(client) do
    case Tesla.get(client, "/admin/collections?action=LIST") do
      {:ok, %{body: %{"collections" => collections}}} ->
        collections
    end
  end

  def aliases(client) do
    case Tesla.get(client, "/admin/collections?action=LISTALIASES") do
      {:ok, %{body: %{"aliases" => aliases}}} ->
        Map.keys(aliases)
    end
  end

  def request_status(client, request_id) do
    case Tesla.get(client, "/admin/collections?action=REQUESTSTATUS&requestid=#{request_id}") do
      {:ok,
       %{
         body: %{
           "exception" => %{"msg" => detail},
           "status" => %{"state" => "failed", "msg" => message}
         }
       }} ->
        puts("FAILED", "#{message} [#{detail}]")

      {:ok, %{body: %{"status" => %{"state" => state, "msg" => message}}}} ->
        puts(String.upcase(state), message)

      _ ->
        puts("UNKNOWN", request_id)
    end
  end

  def request(client, uri) do
    case Tesla.get(client, uri) do
      {:ok, %{status: status}} when status in 200..299 ->
        puts("SUCCESS", uri)
        :success

      _ ->
        puts("ERROR", uri)
        :error
    end
  end

  def apply_mapper(doc, mapper) when is_list(mapper) do
    mapper
    |> Enum.reduce(doc, &mapper_reducer/2)
  end

  def mapper_reducer({:delete, field}, doc) do
    Map.delete(doc, field)
  end

  def mapper_reducer({:copy, from, to}, doc) do
    case doc[from] do
      nil -> doc
      value -> Map.put(doc, to, value)
    end
  end

  def mapper_reducer({:copy, from, to, template}, doc) do
    case doc[from] do
      nil -> doc
      value -> Map.put(doc, to, EEx.eval_string(template, assigns: [input: value]))
    end
  end

  def mapper_reducer({:rename, from, to}, doc) do
    case doc[from] do
      nil ->
        doc

      value ->
        doc
        |> Map.put(to, value)
        |> Map.delete(from)
    end
  end

  def mapper_reducer({:rename, from, to, template}, doc) do
    case doc[from] do
      nil ->
        doc

      value ->
        doc
        |> Map.put(to, EEx.eval_string(template, assigns: [input: value]))
        |> Map.delete(from)
    end
  end

  def remove_fields(doc) do
    @ignore_fields
    |> Enum.reduce(doc, &remove_reducer/2)
  end

  def remove_reducer(field, acc) do
    Map.delete(acc, field)
  end

  def collection_mapper(
        {name,
         %{
           "configName" => config_name,
           "shards" => shards,
           "replicationFactor" => replication_factor,
           "router" => %{"name" => router_name, "field" => router_field}
         }}
      ) do
    %{
      name: name,
      config_name: config_name,
      shards: Enum.count(shards),
      replication_factor: replication_factor,
      router_name: router_name,
      router_field: router_field
    }
  end

  def collection_mapper(
        {name,
         %{
           "configName" => config_name,
           "shards" => shards,
           "replicationFactor" => replication_factor,
           "router" => %{"name" => router_name}
         }}
      ) do
    %{
      name: name,
      config_name: config_name,
      shards:
        shards
        |> Map.to_list()
        |> Enum.map(&shard_mapper/1),
      replication_factor: replication_factor,
      router_name: router_name
    }
  end

  def shard_mapper({name, %{"state" => state, "health" => health, "replicas" => replicas}}) do
    %{
      name: name,
      state: String.to_atom(state),
      health: String.to_atom(health),
      replicas:
        replicas
        |> Map.to_list()
        |> Enum.map(&replica_mapper/1)
    }
  end

  def replica_mapper(
        {name,
         %{
           "base_url" => base_url,
           "core" => core,
           "force_set_state" => force_set_state,
           "node_name" => node_name,
           "state" => state,
           "type" => type
         }}
      ) do
    %{
      name: name,
      base_url: base_url,
      core: core,
      force_set_state: force_set_state,
      node_name: node_name,
      state: String.to_atom(state),
      type: String.to_atom(type)
    }
  end

  def alias_mapper({name, collection}) do
    %{name: name, collection: collection}
  end
end
