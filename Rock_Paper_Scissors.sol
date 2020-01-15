pragma solidity ^0.5.0;

// The smart contract for Rock-Paper-Scissors game
contract RockPaperScissors {
    // There are two sides of a contract in this game and each of them makes a preferred move
    // Available options: 'rock', 'paper' and 'scissors'
    
    struct Move {
        uint8 _name;
        uint8 _stonger_than;
        uint8 _weaker_than;
    }
    
    string public possibleMoves = "'rock', 'paper', 'scissors'";
    
    string constant ROCK = "rock";
    string constant PAPER = "paper";
    string constant SCISSORS = "scissors";    

    mapping (string => uint8) _map_moves;
    mapping (string => Move) _available_moves;
    
    Move private _party1_move;
    Move private _party2_move;

    //parties' addresses
    address payable private _party1_address;
    address payable private _party2_address;
    
    bool private _party1_has_decided;
    bool private _party2_has_decided;

    // In order to be accepted as a party to this contract, one has to pay the fee to enter
    uint256 private fee;

    // The constructor used for mapping of different outcomes
    constructor() public {
        _map_moves[ROCK] = 1;
        _map_moves[PAPER] = 2;
        _map_moves[SCISSORS] = 3;
        
        Move memory move_rock;
        Move memory move_paper;
        Move memory move_scissors;
        
        move_rock._name = _map_moves[ROCK];
        move_rock._stonger_than = _map_moves[SCISSORS];
        move_rock._weaker_than = _map_moves[PAPER];

        move_paper._name = _map_moves[PAPER];
        move_paper._stonger_than = _map_moves[ROCK];
        move_paper._weaker_than = _map_moves[SCISSORS];

        move_scissors._name = _map_moves[SCISSORS];
        move_scissors._stonger_than = _map_moves[PAPER];
        move_scissors._weaker_than = _map_moves[ROCK];
        
        _available_moves[ROCK] = move_rock;
        _available_moves[PAPER] = move_paper;
        _available_moves[SCISSORS] = move_scissors;
        
        fee = 1 ether;
    }
    
    // Modifiers
    modifier canAnotherPartyJoin() {
        string memory errMsgMaxNumber = "It is not possible to join. Maximum number of parties is 2.";
        require(_party1_address == address(0) || _party2_address == address(0), errMsgMaxNumber);
        _;
    }
    
    modifier isFeeCorrect() {
        string memory errMsgFee = "1 ETH needs to be paid to participate in the contract.";
        require(msg.value == fee, errMsgFee);
        _;
    }
    
    modifier isContractParty() {
        string memory errMsgNotParty = "You are not authorized for this because you are not a party in this contract.";
        require(msg.sender == _party1_address || msg.sender == _party2_address, errMsgNotParty);
        _;
    }
    
    modifier isMoveValid(string memory player_move) {
        string memory errMsgInvalidMove = "You need to pick out of available moves. It should be one of: 'rock', 'paper' or 'scissors'.";
        uint8 pickedKey = _map_moves[player_move];
        require(pickedKey != 0, errMsgInvalidMove);
        _;
    }
    
    modifier movesNotMade() {
        string memory errMsgMovesNotMade = "Not all the moves have been made.";
        require(_party1_has_decided && _party2_has_decided, errMsgMovesNotMade);
        _;
    }

    // Functions
    function join() external payable 
        canAnotherPartyJoin() // First check if the party can join
        isFeeCorrect() // Then check if the party is paying the correct fee
        // If all conditions are met, the contract can proceed
    {
        if (_party1_address == address(0))
            _party1_address = msg.sender;
        else
            _party2_address = msg.sender;
    }
    
    function makeMove(string calldata player_move) external 
        isContractParty()                      // Check if the party is participating in the contract
        isMoveValid(player_move)    // Check if the party has chosen one of the valid moves
    {
        if (msg.sender == _party1_address && !_party1_has_decided) {
            _party1_move = _available_moves[player_move];
            _party1_has_decided = true;
            
        } else if (msg.sender == _party2_address && !_party2_has_decided) {
            _party2_move = _available_moves[player_move];
            _party2_has_decided = true;
        }
    }
    
    function seeResult() external 
        isContractParty()          // Check if the party is participating in the contract
        movesNotMade() // Check if both parties have made their moves
    {
        if(_party1_move._name == _party2_move._name) { 
            _party1_address.transfer(fee); 
            _party2_address.transfer(fee);
        } else if (_party1_move._stonger_than == _party2_move._name) {
            _party1_address.transfer(address(this).balance);
        } else {
            _party2_address.transfer(address(this).balance);
        }
        
        // Reset the contract
        _party1_address = address(0);
        _party2_address = address(0);

        _party1_has_decided = false;
        _party2_has_decided = false;
    }
}