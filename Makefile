elm-package := node_modules/.bin/elm-package
elm-make := node_modules/.bin/elm-make
elm-live := node_modules/.bin/elm-live

$(elm-package):
	npm install elm elm-live

.venv/bin/python:
	.venv/bin/pip install six requests kinto-wizard

.venv/bin/kinto-wizard: .venv/bin/python

install: elm-package.json $(elm-package)
	$(elm-package) install
	virtualenv .venv/


build:
	$(elm-make) Main.elm --output app.js

live: install
	$(elm-live) Main.elm --output app.js --open

debug: install
	$(elm-live) Main.elm --output app.js --open --debug

clean:
	rm -fr elm-stuff node_modules .venv
	rm -f app.js

update-admin: .venv/bin/kinto-wizard
	sed -i 's/\t/    /g' initialization.yml
	.venv/bin/kinto-wizard load --server https://focus-risk.alwaysdata.net/v1 --auth marianne initialization.yml

create-user: .venv/bin/python
	.venv/bin/python scripts/create_user.py
