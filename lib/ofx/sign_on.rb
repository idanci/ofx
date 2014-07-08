module OFX
  class SignOn < Foundation
    attr_accessor :language
    attr_accessor :fi_id
    attr_accessor :fi_name

    def to_hash
      {
        :language => language,
        :fi_id    => fi_id,
        :fi_name  => fi_name
      }
    end
  end
end
