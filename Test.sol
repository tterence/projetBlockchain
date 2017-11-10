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
        uint id;
    }
    struct ResponseList{
        Response[] replist;
    }
    mapping(address => ResponseList) listResp;
    //mapping(address => Response) responses;
    //array d'utilisateur
    function Test() public{
    }
    modifier destIsNotExp(address _d) { 
        require(msg.sender != _d); 
        _; 
    }
    function sendDemand(address _dest, uint _test) destIsNotExp(_dest) public{
        //if (msg.sender != exp) return;
        state = State.PENDING;
        exp = msg.sender;
        demands[exp].dest = _dest;
        demands[exp].test = _test;
        listResp[_dest].replist.push(
            Response(
                Demand(_dest,_test),
                exp,
                state,
                listResp[_dest].replist.length));
    }
    function sendResponse(State _state, uint _id) public{
        //if (msg.sender == _dest) return;
        //if (responses[_dest].state == State.NONE) return;
        //or if (state == State.NONE) return;
        address _exp = msg.sender;
        if (_state == State.ACCEPTED){
            state = State.ACCEPTED;
            for (uint i=0; i<listResp[_exp].replist.length; i++){
                if(listResp[_exp].replist[i].id == _id){
                    listResp[_exp].replist[i].state = state;
                    listCV[listResp[_exp].replist[i].exp].list.push(
                        listResp[_exp].replist[i].demand
                        );
                }
            }
        }
        else{
            state = State.REJECTED;
        }
    }/*
    function getStatus(address add)constant public returns(uint[]){
        Demand[] truc = listCV[add].list;
        uint[] ret;
        for (uint i=0;  i<truc.length;i++){
            ret.push(truc[i].test);
        }
        return ret;
    }*/
    function getCv(address add)constant public returns(address[], uint[]){
        Demand[] memory truc = listCV[add].list;
        uint leng = truc.length;
        uint[] memory _test = new uint[](leng);
        address[] memory _add = new address[](leng);
        for (uint i=0;  i<truc.length;i++){
            _test[i] = truc[i].test;
            _add[i] = truc[i].dest;
        }
        return (_add, _test);
    }
    function getAllResponses(address add) public constant returns(address[],uint[],address[],uint[],uint[]){
        uint len = listResp[add].replist.length;
        Response[] memory resp = listResp[add].replist;
        uint[] memory idlist = new uint[](len);
        uint[] memory statelist = new uint[](len);
        uint[] memory testlist = new uint[](len);
        address[] memory destlist = new address[](len);
        address[] memory explist = new address[](len);
        for (uint i = 0;i<len; i++){
            destlist[i] = resp[i].demand.dest;
            testlist[i] = resp[i].demand.test;
            idlist[i] = resp[i].id;
            explist[i] = resp[i].exp;
            statelist[i] = uint(resp[i].state);
        }
        return (destlist,testlist,explist,statelist,idlist);
    }
}