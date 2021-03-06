class Specinfra::HostInventory::Parser::Redhat::Base::Service < Specinfra::HostInventory::Parser::Linux::Service
  class << self
    def parse(cmd_ret)
      services = {}
      lines = cmd_ret.split(/\n/)
      lines.each do |line|
        status = line.split("\t")
        next unless status.count == 8
        service = status[0].strip
        enabled = status[4].include?(':on') # level 3
        cmd = backend.command.get(:check_service_is_running, service)
        services[service] = {
          enabled: enabled,
          running: backend.run_command(cmd).success?
        }
      end
      services
    end
  end
end
