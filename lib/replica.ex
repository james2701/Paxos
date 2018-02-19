
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Replica do

def start config, database, monitor do
  IO.puts ["          Starting server ", DAC.node_ip_addr()]
  config   = Map.put config, :server_num, server_num  


  send paxos, { :config, replica, acceptor, leader }
end # start

end # Server

