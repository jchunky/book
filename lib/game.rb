ATTRS = {
  key: "",
  name: "",
  href: "",
  rank: 0,
  rating: 0.0,
  voters: 0,
  year: 0,
  players: {},
  play_ranks: {},
  location: "",
  shelf: "",
  category: "",
  ts_added: "",
  rules_url: "",
  difficulty: "",
  sell_product: "",
  employees_teachable: 0,
}

Game = Struct.new(*ATTRS.keys, keyword_init: true) do
  def initialize(args)
    super(ATTRS.map { |attr, default| [attr, args.fetch(attr, default)] }.to_h)
  end

  def merge(other)
    Game.new(members.map { |attr| [attr,  merge_attr(other, attr)] }.to_h)
  end

  def merge_attr(other, attr)
    value = send(attr)
    return value.merge(other.send(attr)) if value.respond_to?(:merge)

    value.present? ? value : other.send(attr)
  end

  def add_player_count(month, play_count, play_rank)
    merge(Game.new(
      players: { month.to_s => play_count },
      play_ranks: { month.to_s => play_rank }
    ))
  end

  def trend
    if in_top_100? && !in_top_100_last_year?
      :new
    elsif !in_top_100? && in_top_100_last_year?
      :leaving
    elsif in_top_100?
      :top_100
    else
      :out
    end
  end

  def in_top_100_in_last_two_years?
    in_top_100? || in_top_100_last_year?
  end

  def in_top_100?
    top_ranked?(play_rank)
  end

  def in_top_100_last_year?
    top_ranked?(play_rank_last_year)
  end

  def was_in_top_100?
    years_in_top_100.positive?
  end

  def play_rank
    play_ranks[TopPlayed.last_year.to_s].to_i
  end

  def play_rank_last_year
    play_ranks[(TopPlayed.last_year - (Bgg::BY_MONTH ? 1.month : 1.year)).to_s].to_i
  end

  def player_count
    players[TopPlayed.last_year.to_s].to_i
  end

  def years_in_top_100
    @years_in_top_100 ||= play_ranks.values.count(&method(:top_ranked?))
  end

  def top_ranked?(rank)
    rank.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
