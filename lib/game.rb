Game = Struct.new(
  :href,
  :name,
  :rank,
  :rating,
  :voters,
  :year,

  :players,
  :play_ranks,

  keyword_init: true
) do
  def initialize(args)
    super
    self.players ||= {}
    self.play_ranks ||= {}
  end

  def add_player_count(month, play_count, play_rank)
    self.players[month.to_s] = play_count
    self.play_ranks[month.to_s] = play_rank
  end

  def merge(other)
    Game.new(
      href: href,
      name: name,
      rank: rank || other.rank,
      rating: rating || other.rating,
      voters: voters || other.voters,
      year: year || other.year,
      players: players.merge(other.players),
      play_ranks: play_ranks.merge(other.play_ranks),
    )
  end

  def player_count
    players[TopPlayed.last_year.to_s].to_i
  end

  def play_rank
    play_ranks[TopPlayed.last_year.to_s].to_i
  end

  def recent?
    year.to_i > Bgg::MAX_GAME_YEAR
  end

  def was_in_top_100_for_6_years?
    play_ranks
      .select { |k, v| k.to_i >= year.to_i + Bgg::YEARS_OLD }
      .values
      .any?(&method(:top_ranked?))
  end

  def was_in_top_100?
    play_ranks
      .values
      .any?(&method(:top_ranked?))
  end

  def trend
    if top_ranked?(play_rank)
      :up
    elsif was_in_top_100_for_6_years?
      :even
    else
      :down
    end
  end

  def top_ranked?(rank)
    rank.to_i.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
