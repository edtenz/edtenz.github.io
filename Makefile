
.PHONY run:
run:
	@echo "Running hugo server in debug mode..."
	hugo server -D

.PHONY build:
build:
	@echo "Building hugo site..."
	hugo

.PHONY deploy:
deploy:
	@echo "Deploying hugo site to GitHub Pages..."
	git push origin master

.PHONY new:
new:
	@echo "Creating new post..."
	hugo new posts/new-post.md