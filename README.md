# SolrCli

CLI example application to show [Do It](https://github.com/rzcastilho/do_it) features.

Consists in a group of commands to execute things at [Apache Solr](https://solr.apache.org/).

Some features...

- `collections`
  - `compare`   Compare collections total documents between Solr's
  - `delete`    Delete documents from a Solr collection
  - `copy`      Copy a collection from a Solr to another
  - `status`    Get collection status
- `config`
  - `delete`    Delete Solr collections
  - `create`    Create collections and aliases in Solr Target based on an existing Solr Source
- `maintain`
  - `status`    Get collection backup/restore status
  - `restore`   Restore Solr collections
  - `backup`    Backup Solr collections
- `store`
  - `template`  Manage templates
  - `url`       Manage Solr Base URL's

This is a working in progress... use at your own risk.
