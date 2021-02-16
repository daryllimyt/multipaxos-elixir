# Daryl Lim (dyl17) and Marian Lukac (ml11018)

defmodule Configuration do

def node_id(config, node_type, node_num \\ "") do
  Map.merge config,
  %{
    node_type:     node_type,
    node_num:      node_num,
    node_name:     "#{node_type}#{node_num}",
    node_location: Util.node_string(),
  }
end

# -----------------------------------------------------------------------------

def params :default do
  %{
  max_requests: 1,		# max requests each client will make
  client_sleep: 2,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  5_0,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :scaling10 do
  %{
  max_requests: 10,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end


# -----------------------------------------------------------------------------

def params :scaling100 do
  %{
  max_requests: 100,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :scaling1000 do
  %{
  max_requests: 1000,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :scaling5000 do
  %{
  max_requests: 5000,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :scaling10000 do
  %{
  max_requests: 10000,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  10,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :scaling50000 do
  %{
  max_requests: 50000,		# max requests each client will make
  client_sleep: 0,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  10,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :normal_load do
  %{
  max_requests: 500,		# max requests each client will make
  client_sleep: 2,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  5_00,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :normal_smaller do
  %{
  max_requests: 5_0,		# max requests each client will make
  client_sleep: 2,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:broadcast,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1_00,		# print transaction log summary every print_after msecs

  crash_server: %{},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end
# -----------------------------------------------------------------------------

def params :crash_1 do
  %{
  max_requests: 500,		# max requests each client will make
  client_sleep: 2,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:quorum,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1_000,		# print transaction log summary every print_after msecs

  crash_server: %{1=> 300},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :crash_4 do
  %{
  max_requests: 500,		# max requests each client will make
  client_sleep: 2,		# time (ms) to sleep before sending new request
  client_stop:  60_000,		# time (ms) to stop sending further requests
  client_send:	:quorum,	# :round_robin, :quorum or :broadcast

  n_accounts:   100,		# number of active bank accounts
  max_amount:   1_000,		# max amount moved between accounts

  print_after:  1_000,		# print transaction log summary every print_after msecs

  crash_server: %{1=> 300, 2=> 320, 3=> 330},
  # For replicas, max num additional commands that can be proposed
  window_size: 100
  }
end

# -----------------------------------------------------------------------------

def params :faster do
  config = params :default	# settings for faster throughput
 _config = Map.merge config,
  %{
  # ADD YOUR OWN PARAMETERS HERE
  }
end

# -----------------------------------------------------------------------------

def params :debug1 do		# same as :default with debug_level: 1
  config = params :default
 _config = Map.put config, :debug_level, 1
end

def params :debug3 do		# same as :default with debug_level: 3
  config = params :default
 _config = Map.put config, :debug_level, 3
end

# ADD YOUR OWN PARAMETER FUNCTIONS HERE

end # module ----------------------------------------------------------------

