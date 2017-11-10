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
        exp = msg.sender;
    }
    function sendDemand(address _dest, uint _test) public{
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
    function getAllResponses(address add) public view returns(address[],uint[],address[],uint[],uint[]){
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