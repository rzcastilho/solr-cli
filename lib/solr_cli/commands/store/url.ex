defmodule SolrCli.Commands.Store.Url do
  use DoIt.Command,
    description: "Manage Solr Base URL's"

  alias TableRex.Table

  argument(:action, :string, "Operation", allowed_values: ["set", "list"])
  option(:label, :string, "Label", alias: :l)
  option(:url, :string, "Url", alias: :u)

  def run(%{action: "set"}, %{label: label, url: url}, %{config: %{"url" => urls}}) do
    upsert_url("url", urls, label, url)
  end

  def run(%{action: "set"}, %{label: label, url: url}, _) do
    upsert_url("url", %{}, label, url)
  end

  def run(%{action: "set"}, _, context) do
    IO.puts("Please, inform the label and url options!")
    help(context)
  end

  def run(%{action: "list"}, _, %{config: %{"url" => urls}}) do
    rows =
      urls
      |> Map.to_list()
      |> Enum.map(fn {label, url} -> [label, url] end)

    Table.new(rows, ["Label", "URL"])
    |> Table.render!()
    |> IO.puts()
  end

  def run(%{action: "list"}, _, _) do
    IO.puts("base url definitions not found")
  end

  defp upsert_url(name, map, label, url) do
    DoIt.Commfig.set(name, Map.put(map, label, url))
  end
end
