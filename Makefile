elm-package := node_modules/.bin/elm-package
elm-make := node_modules/.bin/elm-make
elm-live := node_modules/.bin/elm-live

$(elm-package):
	npm install elm elm-live

install: elm-package.json $(elm-package)
	$(elm-package) install

build:
	$(elm-make) Main.elm --output app.js

live: install
	$(elm-live) Main.elm --output app.js --open

debug: install
	$(elm-live) Main.elm --output app.js --open --debug

clean:
	rm -fr elm-stuff node_modules
	rm -f app.js

update-admin:
	sed -i 's/\t/    /g' initialization.yml
	kinto-wizard load --server https://focus-risk.alwaysdata.net/v1 --auth marianne initialization.yml
