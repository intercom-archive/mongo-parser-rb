# MongoParserRB

Parse and evaluate MongoDB queries in Ruby. MongoParserRB is useful for checking if already loaded documents match a query, without the overhead of making requests to the database.

Parse a query:

```ruby
q = MongoParserRB::Query.parse({:comment_count => 5})
```

Once a query has been parsed you can check if individual documents match a query:

```ruby
q.matches_document?({:comment_count => 4}) => false
q.matches_document?({:comment_count => 5}) => true
```

You can use MongoDB's conditional operators, specify them as symbols:

```ruby
q = MongoParserRB::Query.parse({:comment_count => {:$gt => 5, :$lt => 10}})
q.matches_document?({:comment_count => 11}) => false
q.matches_document?({:comment_count => 6}) => true
```

The following operators are currently supported: `$and`, `$or`, `$in`, `$nin`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`.

Regexps are also supported:

```ruby
q = MongoParserRB::Query.parse({:"email" => /gmail/})
q.matches_document?({:email => "ben@intercom.io"}) => false
q.matches_document?({:email => "ciaran@gmail.com"}) => true
```

MongoDB's dot field syntax can be used:

```ruby
q = MongoParserRB::Query.parse({:"author.name" => "Ben"})
q.matches_document?({:author => {:name => "Ciaran"}}) => false
q.matches_document?({:author => {:name => "Ben"}}) => true
```

## Installation

Add this line to your application's Gemfile:

    gem 'mongo-parser-rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo-parser-rb
