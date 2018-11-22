class Game < Struct.new(:data)
  def build
    attrs = attributes.map { |a| [a, send(a)] }.to_h
    OpenStruct.new(attrs)
  end
end
