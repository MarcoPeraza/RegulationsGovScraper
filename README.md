# Regulation Comment Scraper

## Step 1 & 2 Combined

`scrape.rb DOCKET_ID [API_KEY] | make_html.rb`

## Step 1: Scrape

scrape.rb queries the regulations.gov API to download the metadata of all the comments on a particular docket. It outputs JSON.

`scrape.rb DOCKET_ID [API_KEY]`

Example:\
`scrape.rb NIST-2021-0007 NotARealKeyw89dJAKDjf93NotARealKey`

JSON is saved to `comments_[timestamp].json`

## Step 2: Generate HTML

make_html.rb generates HTML from the specified JSON file. Can also be chained from scrape.rb (see above)

`make_html.rb comments_[timestamp].json`

The HTML document is saved to `comments_[timestamp].json.html`

## API Key

Without an API key, application will default to the demo key and likely fail.

Request a key at https://open.gsa.gov/api/regulationsgov/

## Known Issues

- Does not correctly handle documents with more than 5000 comments
- No rate-limiting on API calls

## Authorship

Created by Marco A. Peraza

HTML output uses jQuery and DataTables.

Not an official work of the US government.