#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'json'

if (ARGV.length == 0 || ARGV.length > 2 || ["-h", "--help", "-?", "/?"].include?(ARGV[0]))
    puts "ERROR: Invalid parameters"
    puts ""
    puts "Usage: scrape.rb DOCKET_ID [API_KEY]"
    puts "Example: scrape.rb NTIA-2021-0002 gjekwWKTJD1289dJAKDjf93"
    puts "                                     (not a valid API key)"
    puts ""
    puts "JSON output is written to comments_[timestamp].json"
    puts "To generate HTML table: make_html.rb comments_[timestamp].json"
    puts "In one step: scrape.rb DOCKET_ID [APID_KEY] | make_html.rb"
    puts ""
    puts "Without an API key, application will hang at under 30 comments retrieved."
    puts "Request a key at https://open.gsa.gov/api/regulationsgov/"
    puts ""
    puts "This software has no affiliation with the United States government."
    exit 1
end


API_KEY = ARGV[1] || "DEMO_KEY"

# TODO: add rate limiting. 1000 requests per hour
def reggov_request(endpoint, params={})
    uri = URI("https://api.regulations.gov/v4/" + endpoint)
    uri.path.gsub!('//', '/') # allow caller to either omit or include leading slash in endpoint
    uri.query = URI.encode_www_form(params.merge({"api_key" => API_KEY}))
    res = Net::HTTP.get_response(uri)
    raise "Failed Request" unless (res.is_a?(Net::HTTPSuccess))
    return JSON.parse(res.body)
end

def get_documents(docket_id)
    response = reggov_request("/documents", "filter[docketId]" => docket_id)

    return response["data"].map {|d|
        {id: d["id"],
         title: d["attributes"]["title"],
         object_id: d["attributes"]["objectId"]}
    }
end

# NOTE: does not work if document has more than 5000 comments. For documents with >5000 comments, a different technique
# is required. See documentation at https://open.gsa.gov/api/regulationsgov/#searching-for-comments-1
def get_comments(object_id)
    comments = []

    page_number = 1
    while true
        # Do not remove sort field, will cause duplicates
        response = reggov_request("/comments", "filter[commentOnId]" => object_id,
                                               "api_key" => API_KEY,
                                               "page[size]" => 250,
                                               "page[number]" => page_number,
                                               "sort" => "lastModifiedDate" )

        comments += response["data"].map { |c| c["id"] }

        if response["meta"]["hasNextPage"] then page_number += 1 else break end
    end

    return comments
end

def get_comment(comment_id)
    response = reggov_request("/comments/#{comment_id}", include: "attachments")
    c = response["data"]["attributes"]

    comment = {
         organization: c["organization"],
         firstName: c["firstName"],
         lastName: c["lastName"],
         city: c["city"],
         state: c["stateProvinceRegion"],
         country: c["country"],
         id: comment_id,
         comment: c["comment"]
    }
    comment["attachments"] = response["included"]&.map { |a| {title: a.dig("attributes","title"),
                                                              urls: a.dig("attributes").dig("fileFormats")&.map { |f| f["fileUrl"]} }
                                                       }

    return comment
end

def progress(current, target)
    print "\r"
    pad_to = target.to_s.length
    print "#{current.to_s.rjust(pad_to, "0")} of #{target}"
    $stdout.flush
end

docket_id = ARGV[0]

documents = get_documents(docket_id)
documents.each do |d|
    d[:comments] = get_comments(d[:object_id])

    num_comments = d[:comments].length
    puts "Getting #{num_comments} comments for document #{d[:id]} - #{d[:title]}"

    cur = 1
    d[:comments].map! do |c|
        progress(cur, num_comments)
        cur += 1
        get_comment(c)
    end
    print "\n"
end

output_json = JSON.pretty_generate(documents)

File.write("comments_#{Time.now.to_i}.json", output_json)