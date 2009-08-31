# This Hack is for Merb 1.0.x only
if Merb::VERSION =~ /^1\.0/
  puts "~~ Enabling run_later via ./merb/hacks/run_later_fix.rb ~~"

  class Merb::BootLoader::BackgroundServices < Merb::BootLoader
    # Start background services, such as the run_later worker thread.
    #
    # ==== Returns
    # nil
    #
    # :api: plugin
    def self.run
      Merb::Worker.start unless Merb.testing? || Merb::Worker.started?
      nil
    end
  end

  module Merb
    class Worker
      class << self
        # ==== Returns
        # Whether the Merb::Worker instance is already started.
        #
        # :api: private
        def started?
          !@worker.nil?
        end
      end
    end
  end

  module Merb
    module Rack
      class AbstractAdapter
        # Fork a server on the specified port and start the app.
        #
        # ==== Parameters
        # port<Integer>:: The port to start the server on
        # opts<Hash>:: The hash of options, defaults to the @opts 
        #   instance variable.  
        #
        # :api: private
        def self.start_at_port(port, opts = @opts)
          at_exit do
            Merb::Server.remove_pid(port)
          end

          # If Merb is daemonized, trap INT. If it's not daemonized,
          # we let the master process' ctrl-c control the cluster
          # of workers.
          if Merb::Config[:daemonize]
            Merb.trap('INT') do
              Merb.exiting = true
              stop
              Merb.logger.warn! "Exiting port #{port}\n"
              exit_process
            end
            # If it was not fork_for_class_load, we already set up
            # ctrl-c handlers in the master thread.
          elsif Merb::Config[:fork_for_class_load]
            if Merb::Config[:console_trap]
              Merb::Server.add_irb_trap
            end
          end

          # In daemonized mode or not, support HUPing the process to
          # restart it.
          Merb.trap('HUP') do
            Merb.exiting = true
            stop
            Merb.logger.warn! "Exiting port #{port} on #{Process.pid}\n"
            exit_process
          end

          # ABRTing the process will kill it, and it will not be respawned.
          Merb.trap('ABRT') do
            Merb.exiting = true
            stopped = stop(128)
            Merb.logger.warn! "Exiting port #{port}\n" if stopped
            exit_process(128)
          end

          # Each worker gets its own `ps' name.
          $0 = process_title(:worker, port)

          # Store the PID for this worker
          Merb::Server.store_pid(port)

          Merb::Config[:log_delimiter] = "#{process_title(:worker, port)} ~ "

          Merb.reset_logger!
          Merb.logger.warn!("Starting #{self.name.split("::").last} at port #{port}")

          # If we can't connect to the port, keep trying until we can. Print
          # a warning about this once. Try every 0.25s.
          printed_warning = false
          loop do
            begin
              # Call the adapter's new_server method, which should attempt
              # to bind to a port.
              new_server(port)
            rescue Errno::EADDRINUSE => e
              if Merb::Config[:bind_fail_fatal]
                Merb.fatal! "Could not bind to #{port}. It was already in use", e
              end
            
              unless printed_warning
                Merb.logger.warn! "Port #{port} is in use, " \
                  "Waiting for it to become available."
                printed_warning = true
              end

              sleep 0.25
              next
            end
            break
          end

          Merb.logger.warn! "Successfully bound to port #{port}"

          Merb::Server.change_privilege

          # Call the adapter's start_server method.
          start_server
        end
      end
    end
  end
end