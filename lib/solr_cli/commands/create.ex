defmodule SolrCli.Commands.Create do
  use DoIt.Command,
    description: "Create collections from a Solr to another"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:source_solr, :string, "Source Solr")
  argument(:target_solr, :string, "Target Solr")

  def run(
        %{
          source_solr: s_solr,
          target_solr: t_solr,
        },
        _options,
        %{config: %{"url" => urls}}
      ) do
    start = DateTime.utc_now()
    source_cli = HttpClient.new(base_url: urls[s_solr])
    target_cli = HttpClient.new(base_url: urls[t_solr])

    IO.puts("#{DateTime.to_iso8601(DateTime.utc_now())} - Fetching configuration from source #{urls[s_solr]}...")
    {collections_config, aliases_config} = Controller.cluster_status(source_cli)

    IO.puts("#{DateTime.to_iso8601(DateTime.utc_now())} - Fetching configuration from target #{urls[t_solr]}...")
    collections_target = Controller.collections(target_cli)
    aliases_target = Controller.aliases(target_cli)
    
    collections =
      collections_config
      |> Enum.filter(fn %{name: name} -> !Enum.any?(collections_target, & &1 == name) end)
      |> Enum.map(&build_uri/1)

    IO.puts("\n#{DateTime.to_iso8601(DateTime.utc_now())} - Creating #{Enum.count(collections)} collections...")
    collections
    |> Enum.each(&Controller.request(target_cli, &1))

    aliases =
      aliases_config
      |> Enum.filter(fn %{name: name} -> !Enum.any?(aliases_target, & &1 == name) end)
      |> Enum.map(&build_uri/1)

    IO.puts("\n#{DateTime.to_iso8601(DateTime.utc_now())} - Creating #{Enum.count(aliases)} aliases...")
    aliases
    |> Enum.each(&Controller.request(target_cli, &1))
    
    finish = DateTime.utc_now()
    IO.puts("\n#{DateTime.to_iso8601(finish)} - Done! (#{DateTime.diff(finish, start)}s)")
  end

  defp build_uri(%{name: name, collection: collection}) do
    "/admin/collections?action=CREATEALIAS&name=#{name}&collections=#{collection}"
  end

  defp build_uri(%{config_name: config_name, name: name, num_shards: num_shards, replication_factor: replication_factor, router_name: router_name, router_field: router_field}) do
    "/admin/collections?action=CREATE&name=#{name}&numShards=#{num_shards}&replicationFactor=#{replication_factor}&collection.configName=#{config_name}&router.name=#{router_name}&router.field=#{router_field}"
  end

  defp build_uri(%{config_name: config_name, name: name, num_shards: num_shards, replication_factor: replication_factor}) do
    "/admin/collections?action=CREATE&name=#{name}&numShards=#{num_shards}&replicationFactor=#{replication_factor}&collection.configName=#{config_name}"
  end

  
end
