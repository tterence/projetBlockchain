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
    function Test(){
        exp = msg.sender;
    }
    function sendDemand(address _dest, uint _test)
    returns(uint)
    {
        if (msg.sender != exp) return;
        state = State.PENDING;
        demands[exp].dest = _dest;
        demands[exp].test = _test;
        listResp[_dest].replist.push(
            Response(
                Demand(_dest,_test),
                exp,
                state,
                listResp[_dest].replist.length));
        return listResp[_dest].replist[0].id;
    }
    function sendResponse(State _state, uint _id)
    returns(uint)
    {
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
            //responses[_exp].state = state;
            //listCV[responses[_exp].exp].list.push(responses[_exp].demand);
        }
        else{
            state = State.REJECTED;
        }
        return listCV[listResp[_exp].replist[0].exp].list[0].test;
    }
    function getStatus(address add)constant returns(uint[]){
        Demand[] truc = listCV[add].list;
        uint[] ret;
        for (uint i=0;  i<truc.length;i++){
            ret.push(truc[i].test);
        }
        return ret;
    }/*
    function getResponses(address add)constant returns(address, uint, address, uint){
        return (responses[add].demand.dest, responses[add].demand.test, responses[add].exp, uint(responses[add].state));
    }*/
    function getAllIds(address add) returns(address[],uint[],address[],uint[],uint[]){
        uint len = listResp[add].replist.length;
        Response[] resp = listResp[add].replist;
        uint[] idlist;
        uint[] statelist;
        uint[] testlist;
        address[] destlist;
        address[] explist;
        for (uint i = 0;i<len; i++){
            destlist.push(resp[i].demand.dest);
            testlist.push(resp[i].demand.test);
            idlist.push(resp[i].id);
            explist.push(resp[i].exp);
            statelist.push(uint(resp[i].state));
        }
        return (destlist,testlist,explist,statelist,idlist);
    }
}