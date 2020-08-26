Game = Struct.new(
  :href,
  :name,
  :rank,
  :rating,
  :voters,
  :year,
  :players,
  :play_ranks,
  :location,
  :shelf,
  :category,
  :ts_added,
  :rules_url,
  :difficulty,
  :sell_product,
  :employees_teachable,
  :key,
  keyword_init: true
) do
  def initialize(args)
    super(
      key: args.fetch(:key),
      name: args.fetch(:name),
      href: args.fetch(:href, ""),
      rank: args.fetch(:rank, 0),
      rating: args.fetch(:rating, 0.0),
      voters: args.fetch(:voters, 0),
      year: args.fetch(:year, 0),
      players: args.fetch(:players, {}),
      play_ranks: args.fetch(:play_ranks, {}),
      location: args.fetch(:location, ""),
      shelf: args.fetch(:shelf, ""),
      category: args.fetch(:category, ""),
      ts_added: args.fetch(:ts_added, ""),
      rules_url: args.fetch(:rules_url, ""),
      difficulty: args.fetch(:difficulty, ""),
      sell_product: args.fetch(:sell_product, ""),
      employees_teachable: args.fetch(:employees_teachable, 0)
    )
  end

  def merge(other)
    Game.new(
      key: key,
      name: name,
      href: merge_attr(other, :href),
      rank: merge_attr(other, :rank),
      rating: merge_attr(other, :rating),
      voters: merge_attr(other, :voters),
      year: merge_attr(other, :year),
      players: merge_attr(other, :players),
      play_ranks: merge_attr(other, :play_ranks),
      location: merge_attr(other, :location),
      shelf: merge_attr(other, :shelf),
      category: merge_attr(other, :category),
      ts_added: merge_attr(other, :ts_added),
      rules_url: merge_attr(other, :rules_url),
      difficulty: merge_attr(other, :difficulty),
      sell_product: merge_attr(other, :sell_product),
      employees_teachable: merge_attr(other, :employees_teachable)
    )
  end

  def merge_attr(other, attr)
    value = send(attr)
    return value.merge(other.send(attr)) if value.is_a?(Hash)

    value.present? ? value : other.send(attr)
  end

  def add_player_count(month, play_count, play_rank)
    self.players[month.to_s] = play_count
    self.play_ranks[month.to_s] = play_rank
  end

  def trend
    if top_ranked?(play_rank)
      :up
    elsif was_in_top_100_for_awhile?
      :even
    else
      :down
    end
  end

  def play_rank
    play_ranks[TopPlayed.last_year.to_s].to_i
  end

  def player_count
    players[TopPlayed.last_year.to_s].to_i
  end

  def recent?
    year.to_i > Bgg::MAX_GAME_YEAR
  end

  def was_in_top_100?
    years_in_top_100.positive?
  end

  def was_in_top_100_for_awhile?
    years_in_top_100 >= Bgg::YEARS_OLD
  end

  def years_in_top_100
    @years_in_top_100 ||= play_ranks.values.count(&method(:top_ranked?))
  end

  def top_ranked?(rank)
    rank.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
