default:
  @just --list

rebuild-pre:
  @git add --intent-to-add .

rebuild: rebuild-pre && rebuild-post
  scripts/rebuild.sh

rebuild-post:
