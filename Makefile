.PHONY: all test clean

COFFEE = node_modules/.bin/coffee
UGLIFY = node_modules/.bin/uglifyjs -d WEB=true

all:

server:
	$(COFFEE) -c -o lib src/server

server-watch:
	$(COFFEE) -c -w -o lib src/server

client:
	$(COFFEE) -c -o public/js src/client

client-watch:
	$(COFFEE) -c -w -o public/js src/client

clean:
	rm -rf lib/*

test:
	node_modules/.bin/mocha --require coffee-script --compilers coffee:coffee-script --recursive ./test

