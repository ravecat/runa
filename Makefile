.PHONY: assets

assets: priv/static/assets/app.js

priv/static/assets/app.js: assets/*
	cd assets && node build.js