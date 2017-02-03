## Running the bot

First install de dependencies

```
bundle
```

Then provide the input in the format `<page_id>,<post_limit>`. The bot will keep reading form the STDIN until it finds an EOF.

For a quick test, you can run

```ruby scraper.rb < tests/small_input.txt```
