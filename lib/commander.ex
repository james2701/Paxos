
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Commander do

def start config, lamda, acceptors, replicas, {b, s, c} do
  waitfor = acceptors
  for dest <- acceptors do
    send dest, {:p2a, self(), {b,s,c}}
  end
  next config, lamda, acceptors, replicas, b, s, c, waitfor
end # start

def next config, lamda, acceptors, replicas, b, s, c, waitfor do
  receive do
    {:p2b, a, bnum} -> 
      waitfor = 
        if b == bnum do waitfor -- a
        else waitfor end
        if b == bnum do
          if length(waitfor) < length(acceptors) / 2 do
            for dest <- replicas do
              send dest, {:decision, s, c}
            end
            next config, lamda, acceptors, replicas, b, s, c, waitfor
          end
        else 
          send lamda, {:preempted, bnum}
          next config, lamda, acceptors, replicas, b, s, c, waitfor
        end
  end

end


end # Commander

