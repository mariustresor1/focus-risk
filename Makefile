elm-package := node_modules/.bin/elm-package
elm-make := node_modules/.bin/elm-make
elm-live := node_modules/.bin/elm-live
uglifyjs := node_modules/.bin/uglifyjs
gh-pages := node_modules/.bin/gh-pages

$(elm-package):
	npm install elm elm-live uglify-js gh-pages

.venv/bin/python:
	virtualenv .venv/
	.venv/bin/pip install six requests kinto-wizard

.venv/bin/kinto-wizard: .venv/bin/python

install: elm-package.json $(elm-package)
	$(elm-package) install

build/app.js: $(elm-package)
	rm -fr build/
	mkdir build/
	cp -fr public/* build/

build: build/app.js
	$(elm-make) src/Main.elm --output build/app.js

optimize: build/app.js
	$(uglifyjs) build/app.js -c -m -o build/app.js

live: install
	$(elm-live) src/Main.elm --warn --dir=public/ --output=public/app.js --open

debug: install
	$(elm-live) src/Main.elm --warn --dir=public/ --output=public/app.js --open --debug

clean:
	rm -fr elm-stuff node_modules .venv build/ public/app.js

deploy: build optimize
	$(gh-pages) --dist build/

update-admin: .venv/bin/kinto-wizard
	sed -i 's/\t/    /g' initialization.yml
	.venv/bin/kinto-wizard load --server https://focus-risk.alwaysdata.net/v1 --auth marianne initialization.yml

create-user: .venv/bin/python
	.venv/bin/python scripts/create_user.py
