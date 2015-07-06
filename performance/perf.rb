require 'benchmark'
require_relative '../lib/mongo-parser-rb'

iterations = 500_000

Benchmark.bm(22) do |bm|
  bm.report('simple query parsing') do
    query_hash = {
      :$or => [
        { aaa: { :$gt => 20 } },
        { bbb: {:$not => {:$gt => 10 }} },
        { ccc: 11 },
        { ddd: 12 },
        { eee: 13 },
        { :fff => { :$in => [1] } }
      ]
    }

    iterations.times do
      MongoParserRB::Query.parse(query_hash)
    end
  end

  bm.report('simple query matching') do
    query = MongoParserRB::Query.parse({
      :$or => [
        { aaa: { :$gt => 20 } },
        { bbb: 10 },
        { ccc: 11 },
        { ddd: 12 },
        { eee: 13 }
      ]
    })

    document = {
      aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5,
      nested1: {
        aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5,
        nested: {
          aaa: 1, bbb: 2, ccc: 3, ddd: 4, eee: 5
        }
      }
    }

    iterations.times do
      query.matches_document?(document)
    end
  end
end
