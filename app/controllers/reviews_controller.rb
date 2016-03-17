class ReviewsController < ApplicationController
  def index
  end

  def search
    begin
      limit = 20

      api_key = "t5467ddjcqmf9xkgq79mez77"
      # item_id = 46664254

      url = "http://api.walmartlabs.com/v1/reviews/#{params[:id]}?apiKey=#{api_key}&format=json"

      resp = HTTParty.get url
      total_reviews = resp.parsed_response["reviewStatistics"]["totalReviewCount"].to_i

      all_reviews = []
      agent = Mechanize.new
      (total_reviews / limit + 1).times do |page_num|
        url = "http://www.walmart.com/reviews/api/product/#{params[:id]}?limit=#{limit}&page=#{page_num + 1}&sort=relevancy&filters=&showProduct=false"
        file = agent.get url
        page = Mechanize::Page.new(nil, {'content-type'=>'text/html'}, JSON.parse(file.body)["reviewsHtml"], nil, agent)

        reviews = page.search("div.customer-review")
        texts = reviews.map{ |review| review.search('.js-customer-review-text') }
        all_reviews << texts.map(&:text)
      end

      all_reviews.flatten.count

      @results = all_reviews.flatten.select{ |text| text =~ Regexp.new(params[:search_string], 'i') }
    rescue Mechanize::ResponseCodeError => e
      @results = [e.inspect]
    end
  end
end
