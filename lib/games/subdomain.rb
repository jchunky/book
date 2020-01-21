class Subdomain < Struct.new(:subdomain_name, :subdomain_id)
  def games
    (1..10)
      .lazy
      .map { |page| url_for_page(page) }
      .map { |url| Utils.read_url(url) }
      .map { |file| Nokogiri::HTML(file) }
      .flat_map(&method(:games_for_doc))
      .uniq { |g| g[:key] }
      .force
  end

  def url_for_page(page)
    "https://boardgamegeek.com/search/boardgame/page/#{page}?sort=rank&advsearch=1&familyids%5B%5D=#{subdomain_id}&sortdir=asc"
  end

  def games_for_doc(doc)
    doc.css('.collection_table')[0].css('tr').drop(1).map do |row|
      rank, _, title, _, rating, voters, *_, shop = row.css('td')
      name = Utils.strip_accents(title.css('a')[0].content)

      {
        key: Utils.generate_key(name),
        subdomain: subdomain_name
      }
    end
  end
end
