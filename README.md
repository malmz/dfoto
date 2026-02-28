# Dfoto



## Development

To start your Phoenix server:

* Run `mix ash.setup` to setup database with migrations
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Postgres full text search (swedish_hunspell)

This app uses postgres full text search. For best results, a language spesific dictionary is used. 
Right now hardcoded to look for a dictionary named `swedish_hunspell` that needs to be created.

Step one is to get dictionaty files (.aff and .dic). they can be found from mozilla or libreoffice.
There might also be distro packages, there is `hunspell-sv` in the AUR. 
The swedish ones look a bit unmaintained (2026), but it's better than nothing. Move the 
dictionary files to `/usr/share/postgres/tsearch_data/sv_se`