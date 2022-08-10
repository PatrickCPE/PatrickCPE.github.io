# Makefile for PatrickCPE.com hosted via github pages
# Uses Jekyll under the hood with the occasional post generated via Org Mode exports

MESSAGE = "default commit message"

default: help

.PHONY : help
help:
	@echo "Targets";
	@echo "Target:";
	@echo "    Description";
	@echo "        Param";
	@echo "            Description";
	@echo "help:";
	@echo "    Show makefile usage";

.PHONY : local
local:
	@bundle exec jekyll serve;

.PHONY: deploy
deploy:
	@bundle exec jekyll build;
	@git add .;
	@git commit -m "$(MESSAGE)";
	@git push origin gh-pages;
