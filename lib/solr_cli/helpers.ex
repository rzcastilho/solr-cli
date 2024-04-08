defmodule SolrCli.Helpers do

  def puts(status, message) when status in ["SUCCESS", "COMPLETED"] do
    [:green, :bright, String.pad_leading(status, 10), :cyan, " ❯ ", :white, :bright, message]
    |> puts()
  end

  def puts(status, message) when status in ["ERROR", "FAILED", "NOTFOUND"] do
    [:red, :bright, String.pad_leading(status, 10), :cyan, " ❯ " , :white, :bright, message]
    |> puts()
  end

  def puts(status, message) when status in ["RUNNING", "SUBMITED"] do
    [:yellow, :bright, String.pad_leading(status, 10), :cyan, " ❯ " , :white, :bright, message]
    |> puts()
  end

  def puts(status, message) do
    [:bright, String.pad_leading(status, 10), :cyan, " ❯ " , :white, :bright, message]
    |> puts()
  end

  defp puts(text) do
    text
    |> IO.ANSI.format()
    |> IO.puts()
  end
  
end
