# README

This README would normally document whatever steps are necessary to get the
application up and running.


# Install

docker volume create --name=word-tracker-gems
docker-compose up


# Commands

```
WordSetImporter.new('comprehensive-japanese', 'word-lists/comprehensive-japanese').call
FrequencyCalculator.new("bccwj", "comprehensive-japanese").call
```
