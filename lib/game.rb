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
    super(
      href: args.fetch(:href),
      name: args.fetch(:name),
      rank: args.fetch(:rank, 0),
      rating: args.fetch(:rating, 0.0),
      voters: args.fetch(:voters, 0),
      year: args.fetch(:year, 0),
      players: args.fetch(:players, {}),
      play_ranks: args.fetch(:play_ranks, {})
    )
  end

  def add_player_count(month, play_count, play_rank)
    self.players[month.to_s] = play_count
    self.play_ranks[month.to_s] = play_rank
  end

  def merge(other)
    Game.new(
      href: href,
      name: name,
      rank: [rank, other.rank].max,
      rating: [rating, other.rating].max,
      voters: [voters, other.voters].max,
      year: [year, other.year].max,
      players: players.merge(other.players),
      play_ranks: play_ranks.merge(other.play_ranks),
    )
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
    play_ranks
      .values
      .any?(&method(:top_ranked?))
  end

  def was_in_top_100_for_awhile?
    play_ranks
      .select { |k, v| k.to_i >= year + Bgg::YEARS_OLD }
      .values
      .any?(&method(:top_ranked?))
  end

  def top_ranked?(rank)
    rank.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
