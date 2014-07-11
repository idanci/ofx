module OFX
  class Account < Foundation
    attr_accessor :balance
    attr_accessor :bank_id
    attr_accessor :currency
    attr_accessor :id
    attr_accessor :transactions
    attr_accessor :type
    attr_accessor :available_balance

    def to_hash
      {
        :balance           => balance ? balance.to_hash : nil,
        :bank_id           => bank_id,
        :currency          => currency,
        :id                => id,
        :transactions      => transactions.map(&:to_hash),
        :type              => type,
        :available_balance => available_balance ? available_balance.to_hash : nil
      }
    end
  end
end
