require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/pride'

require 'mocha/setup'

require 'snp'

# unset any possibly set `SNP_PATH` variable
ENV.delete('SNP_PATH')
