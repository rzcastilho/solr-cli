defmodule SolrCli.Commands.Copy do
  use DoIt.Command,
    description: "Copy a collection from a Solr to another"

  alias SolrCli.HttpClient
  alias SolrCli.Controller

  argument(:source_solr, :string, "Source Solr")
  argument(:source_collection, :string, "Source collection")
  argument(:target_solr, :string, "Target Solr")
  argument(:target_collection, :string, "Target collection")

  option(:query, :string, "Solr query", default: "*:*")
  option(:max, :integer, "Max number of documents to copy", default: 10_000)
  option(:page_size, :integer, "Fetch page size from Solr", default: 100)
  option(:mapper, :string, "Map transformations: \"copy:from:to\" \"rename:from:to\" \"delete:attribute\"", alias: :m, keep: true)

  def run(
    %{source_solr: s_solr, source_collection: s_col, target_solr: t_solr, target_collection: t_col},
    %{query: query, max: max, page_size: page_size} = options,
    %{config: %{"url" => urls} = config}) do
    IO.puts("Copying #{max} maximum of documents from #{urls[s_solr]}/#{s_col} to #{urls[t_solr]}/#{t_col} with query #{query}...")
    source_cli = HttpClient.new(base_url: urls[s_solr])
    target_cli = HttpClient.new(base_url: urls[t_solr])
    source_search = %Controller.Search{client: source_cli, collection: s_col, query: %{"q" => query}, max: max, rows: page_size}
    Controller.reindex_documents(
      source_search,
      target_cli,
      t_col,
      normalize_mappers(
        Map.get(options, :mapper, []),
        Map.get(config, "template", %{})
      )
    )
    IO.puts("\nDone!")
  end

  defp normalize_mappers([], _templates), do: []

  defp normalize_mappers(mapper, templates) when is_bitstring(mapper) do
    normalize_mappers([mapper], templates)
  end

  defp normalize_mappers(mappers, templates) do
    mappers
    |> Enum.map(&map_action/1)
    |> Enum.map(&map_template(&1, templates))
  end

  defp map_action("copy:" <> rest = action) do
    case String.split(rest, ":") do
      [from, to] ->
        {:copy, from, to}
      [from, to, template] ->
        {:copy, from, to, template}
      _ ->
        raise "Invalid format for copy action \"#{action}\""
    end
  end

  defp map_action("rename:" <> rest = action) do
    case String.split(rest, ":") do
      [from, to] ->
        {:rename, from, to}
      [from, to, template] ->
        {:rename, from, to, template}
      _ ->
        raise "Invalid format for rename action \"#{action}\""
    end
  end

  defp map_action("delete:" <> attribute) do
    {:delete, attribute}
  end

  defp map_action(action), do: raise "Invalid action format \"#{action}\""

  defp map_template({_action, _from, _to, template} = action, templates) do
    action
    |> Tuple.delete_at(3)
    |> Tuple.append(templates[template])
  end

  defp map_template(action, _templates), do: action

end
