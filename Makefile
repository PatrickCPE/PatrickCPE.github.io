# Makefile for PatrickCPE.com hosted via github pages
# Uses Jekyll under the hood with the occasional post generated via Org Mode exports

MESSAGE = "default commit message"

default: help

.PHONY : help
help:
	@echo "Targets";
	@echo "help:";
	@echo "    Show makefile usage";
	@echo "clean:";
	@echo "    Clean the generated site html";
	@echo "local:";
	@echo "    Build site and host locally";
	@echo "deploy:";
	@echo "    Build and deploy site via github pages.";
	@echo "        MESSAGE";
	@echo "            Git commit message for this push";
	@echo "";
	@echo "Examples:";
	@echo "make help";
	@echo "make local";
	@echo "make deploy MESSAGE=\"Commit that does stuff :)\"";

.PHONY : local
local:
	@bundle exec jekyll serve;

.PHONY : clean
clean:
	@bundle exec jekyll clean;

.PHONY: deploy
deploy:
	@bundle exec jekyll clean;
	@bundle exec jekyll build;
	@git add .;
	@git commit -m "$(MESSAGE)";
	@git push origin gh-pages;
