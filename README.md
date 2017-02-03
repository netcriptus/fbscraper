## Running the bot

First install the dependencies

```
bundle
```

Then provide the input in the format `<page_id>,<post_limit>`. The bot will keep reading from the STDIN until it finds an EOF.

For a quick test, you can run

```ruby scraper.rb < small_input.txt```
