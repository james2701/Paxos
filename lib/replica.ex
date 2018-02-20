
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Replica do

def start config, leaders, initial_state do
    state = initial_state
    slot_in = 1
    slot_out = 1
    requests = []
    proposals =[]
    decisions = []
end # start

def propose do
   if slot_in < slot_out + WINDOW and c in requests do
       if op
   end
end

def perform k, cid, op do

end

end # Server



