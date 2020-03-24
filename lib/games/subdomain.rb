class Subdomain < Struct.new(:subdomain_name, :subdomain_id)
  def games
    (1..10)
      .lazy
      .map { |page| [page, url_for_page(page)] }
      .map { |page, url| [page, Utils.read_url(url)] }
      .map { |page, file| [page, Nokogiri::HTML(file)] }
      .flat_map(&method(:games_for_doc))
      .uniq { |g| g[:key] }
      .force
  end

  def url_for_page(page)
    "https://boardgamegeek.com/search/boardgame/page/#{page}?sort=rank&sortdir=asc&advsearch=1&familyids%5B0%5D=#{subdomain_id}"
  end

  def games_for_doc((page, doc))
    doc.css('.collection_table')[0].css('tr').drop(1).map do |row|
      begin
        rank, _, title, _, rating, voters, *_, shop = row.css('td')
        name = Utils.strip_accents(title.css('a')[0].content)

        {
          key: Utils.generate_key(name),
          subdomains: [subdomain_name]
        }
      rescue
        report_failure(page)
      end
    end
  rescue
    report_failure(page)
    []
  end

  def report_failure(page)
    p '-' * 80
    p "Failed to process: subdomain name: #{subdomain_name}, subdomain id: #{subdomain_id}, page: #{page}"
  end
end
