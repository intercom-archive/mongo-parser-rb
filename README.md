# MongoParserRB

Parse and evaluate MongoDB queries in Ruby. MongoParserRB is useful for checking if already loaded documents match a query, without the overhead of making requests to the database.

```ruby
> require 'mongo-parser-rb'
> query = MongoParserRB::Query.parse({:comment_count => {:$gt => 5}})
> query.matches_document?({:comment_count => 4})
false
> query.matches_document?({:comment_count => 7})
true

> query = MongoParserRB::Query.parse({:comment_count => {:$gt => 5}, :$or => [{:author_name => 'Ben'}, {:author_name => 'Ciaran}]})
> query.matches_document?({:comment_count => 7, :author_name => "Paul"})
false
> query.matches_document?({:comment_count => 7, :author_name => "Ben"})
true
```

## Installation

Add this line to your application's Gemfile:

    gem 'mongo-parser-rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo-parser-rb

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
