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
    if in_top_100? && !in_top_100_for_a_year?
      :new
    elsif !in_top_100? && in_top_100_last_month?
      :leaving
    elsif in_top_100?
      :top_100
    else
      :out
    end
  end

  def in_top_100_for_a_year?
    12.times.to_a.all? do |i|
      month = (TopPlayed.last_month - i.month).to_s
      rank = play_ranks[month].to_i
      top_ranked?(rank)
    end
  end

  def in_top_100?
    top_ranked?(play_rank)
  end

  def in_top_100_last_month?
    top_ranked?(play_rank_last_month)
  end

  def play_rank
    play_ranks[TopPlayed.last_month.to_s].to_i
  end

  def play_rank_last_month
    play_ranks[(TopPlayed.last_month - 1.month).to_s].to_i
  end

  def player_count
    players[TopPlayed.last_month.to_s].to_i
  end

  def months_in_top_100
    @months_in_top_100 ||= play_ranks.values.count(&method(:top_ranked?))
  end

  def top_ranked?(rank)
    rank.between?(1, Bgg::PLAY_RANK_THRESHOLD)
  end
end
