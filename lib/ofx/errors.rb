module OFX
  class UnsupportedFileError < StandardError; end
  class ParseError           < StandardError
    AMOUNT = "Error while parsing numeric field."
    TIME   = "Error while parsing time field."
  end
end
