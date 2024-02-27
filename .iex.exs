alias SolrCli.{
  Controller,
    HttpClient
}

client = HttpClient.new(base_url: "http://dev.k8s.internal.geofusion/solr")

%{body: %{"cluster" => %{"collections" => collections, "aliases" => aliases}}} =
  Tesla.get!(client, "/admin/collections?action=CLUSTERSTATUS")
