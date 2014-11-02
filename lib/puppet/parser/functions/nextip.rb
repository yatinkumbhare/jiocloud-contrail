##
## nextip
##
module Puppet::Parser::Functions
  newfunction(
    :nextip,
    :type  => :rvalue,
    :arity => 1,
    :doc   => <<-EOS

This function Returns next ip to provided address.

Example:

  nextip('192.168.1.1')

would return 192.168.1.2

    EOS
  ) do |args|
  require 'ipaddr'
  IPAddr.new(args[0]).succ().to_s
  end
end

# vim:sts=2 sw=2
