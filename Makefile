
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  init         Initialize git submodules"
	@echo "  run          Run Hugo server with drafts"
	@echo "  run-prod     Run Hugo server (production mode)"
	@echo "  build        Build Hugo site (production)"
	@echo "  build-drafts Build Hugo site (include drafts/future)"
	@echo "  clean        Remove public/ and resources/_gen/"
	@echo "  deploy       Push to origin master"
	@echo "  publish      Add all, commit, and push"
	@echo "  new-post     Create posts/new-post.md"
	@echo "  new-deep     Create deep/new-deep.html"

.PHONY: init
init:
	git submodule update --init --recursive

.PHONY: run
run:
	@echo "Running Hugo server with drafts..."
	hugo server -D

.PHONY: run-prod
run-prod:
	@echo "Running Hugo server (production mode)..."
	hugo server

.PHONY: build
build:
	@echo "Building Hugo site (production)..."
	hugo

.PHONY: build-drafts
build-drafts:
	@echo "Building Hugo site (include drafts/future)..."
	hugo -D -F

.PHONY: clean
clean:
	@echo "Cleaning public/ and resources/_gen/..."
	rm -rf public resources/_gen

.PHONY: deploy
deploy:
	@echo "Deploying Hugo site to GitHub Pages..."
	git push origin master

.PHONY: publish
publish:
	@echo "Adding, committing and pushing..."
	git add -A
	git commit -m "Publish updates"
	git push origin master

.PHONY: new-post
new-post:
	@echo "Creating new post..."
	hugo new posts/new-post.md

.PHONY: new-deep
new-deep:
	@echo "Creating new deep post..."
	hugo new deep/new-deep.html
