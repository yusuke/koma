require 'parallel'

module Koma
  module Backend
    class Ssh < Base
      attr_reader :host, :options

      def gather
        if host.include?(',')
          list = host.split(',')
          results = Parallel.map(list, in_thread: 4) do |h|
            ssh_out(h, options)
          end
          arr = [list, results].transpose
          result = Hash[*arr.flatten]
        else
          result = ssh_out(host, options)
        end
        result
      end

      def ssh_out(host, options)
        user, host = host.split('@') if host.include?('@')
        set :backend, :ssh
        set :host, host
        set :request_pty, true
        ssh_options = Net::SSH::Config.for(host)
        ssh_options[:user] = user if user
        ssh_options[:keys] = [options[:identity_file]] if options[:identity_file]
        ssh_options[:port] = options[:port] if options[:port]
        set :ssh_options, ssh_options
        out(options[:key])
      end
    end
  end
end
