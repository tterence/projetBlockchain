pragma solidity ^0.4.11;
contract Test{
    struct Demand{
        address dest; //destinataire
        uint test;
    }
    struct CV{
        Demand[] list; //liste de demandes validées
    }
    mapping(address => CV) listCV;
    address exp; //adresse de l'expéditeur
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
        address exp; //adresse du demandeur
        State state;
    }
    mapping(address => Response) responses;
    //array d'utilisateur
    address[] userlist;
    function Test(){
        exp = msg.sender;
        userlist = [
            0xca35b7d915458ef540ade6068dfe2f44e8fa733c,
            0x14723a09acff6d2a60dcdf7aa4aff308fddc160c,
            0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db,
            0x583031d1113ad414f02576bd6afabfb302140225,
            0xdd870fa1b7c4700f2bd7f44238821c26f7392148
        ];
    }
    function sendDemand(address _dest, uint _test){
        if (msg.sender != exp) return;
        state = State.PENDING;
        demands[exp].dest = _dest;
        demands[exp].test = _test;
        responses[_dest].demand = Demand(_dest,_test);
        responses[_dest].exp = exp;
        responses[_dest].state = state;
    }
    function sendResponse(State _state){
        //if (msg.sender == _dest) return;
        //if (responses[_dest].state == State.NONE) return;
        //or if (state == State.NONE) return;
        address _exp = msg.sender;
        if (_state == State.ACCEPTED){
            state = State.ACCEPTED;
            responses[_exp].state = state;
            listCV[responses[_exp].exp].list.push(responses[_exp].demand);
        }
        else{
            state = State.REJECTED;
        }
    }
    function getStatus(address add)constant returns(uint[]){
        Demand[] truc = listCV[add].list;
        uint[] ret;
        for (uint i=0;  i<truc.length;i++){
            ret.push(truc[i].test);
        }
        return ret;
    }
    function getAddresses()constant returns(address[]){
       return userlist;
    }
}