require_relative '../lib/mongo-parser-rb'
require 'benchmark'

iterations = 500_000

Benchmark.bm() do |bm|
  bm.report('simple query parsing') do
    iterations.times do
      MongoParserRB::Query.parse({
        :$or => [
          { aaa: { :$gt => 20 } },
          { bbb: {:$not => {:$gt => 10 }} },
          { ccc: 11 },
          { ddd: 12 },
          { eee: 13 },
          { :fff => { :$in => [1] } }
        ]
      })
    end
  end

  bm.report('simple query matching') do
    q = MongoParserRB::Query.parse({
      :$or => [
        { aaa: { :$gt => 20 } },
        { bbb: 10 },
        { ccc: 11 },
        { ddd: 12 },
        { eee: 13 }
      ]
    })
    large_document = {
      aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5,
      nested1: {
        aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5,
        nested: {
          aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5
        }
      }
    }

    custom_data_query = MongoParserRB::Query.parse({'custom_data.tracked_users' => 10})
    custom_data_doc = { custom_data: { tracked_users: 10 } }

    iterations.times do
      q.matches_document?(large_document)
      q.matches_document?({:comment_count => 5})

      custom_data_query.matches_document?(custom_data_doc)
    end
  end
end
