.PHONY: build deploy
download-data:
	wget --max-redirect 0 https://crawler.developers.italia.it/softwares.yml -O _data/crawler/softwares.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/amministrazioni.yml -O _data/crawler/amministrazioni.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/software_categories.yml -O _data/crawler/software_categories.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/software-open-source.yml -O _data/crawler/software-open-source.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/software-riuso.yml -O _data/crawler/software-riuso.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/software_scopes.yml -O _data/crawler/software_scopes.yml
	wget --max-redirect 0 https://crawler.developers.italia.it/software_tags.yml -O _data/crawler/software_tags.yml

	wget -P _data https://raw.githubusercontent.com/italia/developers.italia.it-data/main/github_members.yml
	wget -P _data https://raw.githubusercontent.com/italia/developers.italia.it-data/main/github_teams.yml
	wget -P _data https://raw.githubusercontent.com/italia/developers.italia.it-data/main/github_tech_list.yml

	wget -P _site/assets https://raw.githubusercontent.com/italia/developers.italia.it-data/main/github_issues.json

bundle-setup:
	gem install bundler:2.1.4
	bundle config set path vendor/

bundle-install: bundle-setup
	bundle install

bundle-install-deployment: bundle-setup
	bundle install --deployment

test:
	npm run lint
	npm run test
	scripts/pa11y.sh
	bundle exec htmlproofer ./_site --assume-extension --check-html --allow-hash-href --empty-alt-ignore --only-4xx --disable-external

local:
	npx webpack-dev-server --config webpack.dev.js --color --progress -d --host 0.0.0.0 | bundle exec jekyll serve --livereload --incremental --host=0.0.0.0 --trace

jekyll-build:
	JEKYLL_ENV=production bundle exec jekyll build
	NODE_ENV=production npm run build
include-npm-deps:
	npm ci
build: | build-bundle-deployment include-npm-deps download-data jekyll-build
build-test: | build test
