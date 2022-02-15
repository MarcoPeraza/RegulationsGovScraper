# Regulation Comment Scraper

## Usage
`scrape.rb DOCKET_ID [API_KEY]`

Example:\
`scrape.rb NIST-2021-0007 NotARealKeyw89dJAKDjf93NotARealKey`

## Output

JSON output is written to comments_[timestamp].json \
Then, to generate HTML table: `make_html.rb comments_[timestamp].json` \
Or all in one step: `scrape.rb DOCKET_ID [API_KEY] | make_html.rb`

## API Key

Without an API key, application will default to the demo key and likely fail.

Request a key at https://open.gsa.gov/api/regulationsgov/

## Known Issues

- Does not correctly handle documents with more than 5000 comments
- No rate-limiting on API calls

## Authorship
Created by Marco A. Peraza

Not an official work of the US government.