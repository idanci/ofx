module OFX
  module Parser
    class BaseParser
      ACCOUNT_TYPES = {
        "CHECKING" => :checking
      }

      TRANSACTION_TYPES = [
        'ATM', 'CASH', 'CHECK', 'CREDIT', 'DEBIT', 'DEP', 'DIRECTDEBIT', 'DIRECTDEP', 'DIV',
        'FEE', 'INT', 'OTHER', 'PAYMENT', 'POS', 'REPEATPMT', 'SRVCHG', 'XFER'
      ].inject({}) { |hash, tran_type| hash[tran_type] = tran_type.downcase.to_sym; hash }

      attr_reader :headers, :body, :html, :errors

      def initialize(options = {})
        @headers = options[:headers]
        @body    = options[:body]
        @html    = Nokogiri::HTML.parse(body)
        @errors  = []
      end

      def bank_accounts
        @bank_accounts ||= build_bank_account
      end

      def credit_cards
        @credit_cards ||= build_credit_card
      end

      def accounts
        return @accounts if @accounts
        @accounts = OFX::Accounts.new

        (bank_accounts + credit_cards).each do |account|
          @accounts << account
        end

        @accounts
      end

      def sign_on
        @sign_on ||= build_sign_on
      end

      private

      def build_bank_account
        html.search("stmttrnrs").each_with_object([]) do |account, list|
          begin
            account_id = account.search("bankacctfrom > acctid").inner_text

            list << OFX::Account.new({
              :bank_id           => account.search("bankacctfrom > bankid").inner_text,
              :id                => account_id,
              :type              => ACCOUNT_TYPES[account.search("bankacctfrom > accttype").inner_text.to_s.upcase],
              :transactions      => build_transactions(account.search("banktranlist > stmttrn"), account_id),
              :balance           => build_balance(account),
              :available_balance => build_available_balance(account),
              :currency          => account.search("stmtrs > curdef").inner_text
            })
          rescue OFX::ParseError => error
            errors << error
          end
        end
      end

      def build_credit_card
        html.search("ccstmttrnrs").each_with_object([]) do |account, list|
          begin
            account_id = account.search("ccstmtrs > ccacctfrom > acctid").inner_text

            list << OFX::Account.new({
              :id           => account_id,
              :transactions => build_transactions(account.search("banktranlist > stmttrn"), account_id),
              :balance      => build_balance(account),
              :currency     => account.search("ccstmtrs > curdef").inner_text
            })
          rescue OFX::ParseError => error
            errors << error
          end
        end
      end

      def build_transactions(transactions, account_id)
        transactions.each_with_object([]) do |transaction, transactions|
          begin
            transactions << build_transaction(transaction, account_id)
          rescue OFX::ParseError => error
            errors << error
          end
        end
      end

      def build_transaction(transaction, account_id)
        OFX::Transaction.new({
          :amount            => build_amount(transaction),
          :amount_in_pennies => (build_amount(transaction) * 100).to_i,
          :fit_id            => transaction.search("fitid").inner_text,
          :memo              => transaction.search("memo").inner_text,
          :name              => transaction.search("name").inner_text,
          :payee             => transaction.search("payee").inner_text,
          :check_number      => transaction.search("checknum").inner_text,
          :ref_number        => transaction.search("refnum").inner_text,
          :posted_at         => build_date(transaction.search("dtposted").inner_text),
          :type              => build_type(transaction),
          :sic               => transaction.search("sic").inner_text,
          :account_id        => account_id
        })
      end

      def build_sign_on
        OFX::SignOn.new({
          :language          => html.search("signonmsgsrsv1 > sonrs > language").inner_text,
          :fi_id             => html.search("signonmsgsrsv1 > sonrs > fi > fid").inner_text,
          :fi_name           => html.search("signonmsgsrsv1 > sonrs > fi > org").inner_text
        })
      end

      def build_type(element)
        TRANSACTION_TYPES[element.search("trntype").inner_text.to_s.upcase]
      end

      def build_amount(element)
        BigDecimal.new(element.search("trnamt").inner_text)
      rescue TypeError => error
        raise OFX::ParseError.new(OFX::ParseError::AMOUNT)
      end

      def build_date(date)
        _, year, month, day, hour, minutes, seconds = *date.match(/(\d{4})(\d{2})(\d{2})(?:(\d{2})(\d{2})(\d{2}))?/)

        date = "#{year}-#{month}-#{day} "
        date << "#{hour}:#{minutes}:#{seconds}" if hour && minutes && seconds

        Time.parse(date)
      rescue TypeError, ArgumentError => error
        raise OFX::ParseError.new(OFX::ParseError::TIME)
      end

      def build_balance(account)
        amount = account.search("ledgerbal > balamt").inner_text.to_f

        OFX::Balance.new({
          :amount => amount,
          :amount_in_pennies => (amount * 100).to_i,
          :posted_at => build_date(account.search("ledgerbal > dtasof").inner_text)
        })
      end

      def build_available_balance(account)
        return nil unless account.search("availbal").size > 0

        amount = account.search("availbal > balamt").inner_text.to_f

        OFX::Balance.new({
          :amount => amount,
          :amount_in_pennies => (amount * 100).to_i,
          :posted_at => build_date(account.search("availbal > dtasof").inner_text)
        })
      end
    end
  end
end
