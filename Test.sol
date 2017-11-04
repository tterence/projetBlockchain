pragma solidity ^0.4.11;
contract Test{
    struct Demand{
        address dest;
        uint test;
    }
    struct CV{
        Demand[] list;
    }
    mapping(address => CV) listCV;
    address public exp;
    mapping(address => Demand) demands;
    enum State {
        NONE,
        ACCEPTED,
        PENDING,
        REJECTED
        
    }
    State public state;
    struct Response{
        Demand demand;
        address exp;
        State state;
    }
    mapping(address => Response) responses;
    function Test(){
        exp = msg.sender;
    }
    function sendDemand(address _dest, uint _test){
        if (msg.sender != exp) return;
        state = State.PENDING;
        demands[exp].dest = _dest;
        demands[exp].test = _test;
        responses[_dest].demand = demands[exp];
        responses[_dest].exp = exp;
        responses[_dest].state = state;
    }
    function sendResponse(address _dest, State _state)
    returns(uint){
        //if (msg.sender == _dest) return;
        //if (responses[_dest].state == State.NONE) return;
        //or if (state == State.NONE) return;
        if (_state == State.ACCEPTED){
            state = State.ACCEPTED;
            responses[_dest].state = state;
            listCV[_dest].list.push(responses[_dest].demand);
        }
        else{
            state = State.REJECTED;
        }
        return listCV[_dest].list[0].test;
    }
    function getStatus(address add)constant returns(uint[]){
        Demand[] truc = listCV[add].list;
        uint[] ret;
        for (uint i=0;  i<truc.length;i++){
            ret.push(truc[i].test);
        }
        return ret;
    }
}