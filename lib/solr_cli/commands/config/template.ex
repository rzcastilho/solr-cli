defmodule SolrCli.Commands.Config.Template do
  use DoIt.Command,
    description: "Manage templates"

  argument(:action, :string, "Operation", allowed_values: ["set", "list"])
  option(:label, :string, "Label", alias: :l)
  option(:template, :string, "Template", alias: :t)

  def run(%{action: "set"}, %{label: label, template: template}, %{config: %{"template" => templates}}) do
    upsert_template("template", templates, label, template)
  end

  def run(%{action: "set"}, %{label: label, template: template}, _) do
    upsert_template("template", %{}, label, template)
  end

  def run(%{action: "list"}, _, %{config: %{"template" => templates}}) do
    templates
    |> Map.to_list()
    |> Enum.each(fn {label, template} -> IO.puts("#{label}\n\t#{template}") end)
  end

  def run(%{action: "list"}, _, _) do
    IO.puts("template definitions not found")
  end

  defp upsert_template(name, map, label, template) do
    DoIt.Commfig.set(name, Map.put(map, label, template))
  end

end
