require 'securerandom' unless defined?(SecureRandom)

module UUID
  def create
    SecureRandom.uuid
  end

  def new
    SecureRandom.uuid
  end

  def create_random
    SecureRandom.uuid
  end

  extend(self)
end
