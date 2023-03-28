pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uma/core/contracts/oracle/implementation/Oracle.sol";

contract Xpredic {
    struct Question {
        uint id;
        string questionText;
        uint256 endTime;
        bool resolved;
        uint correctAnswer;
        mapping(uint => uint) balances;
        mapping(address => mapping(uint => uint)) bets;
    }

    mapping(uint => Question) public questions;
    uint public numQuestions;

    // UMA Priceless Position Manager
    IERC20 public collateralToken;
    Oracle public priceFeed;
    uint public priceIdentifier;

    // Optimism Gateway
    address public gatewayRouter;

    constructor(
        address _collateralToken,
        address _gatewayRouter,
        address _priceFeed,
        uint _priceIdentifier
    ) {
        collateralToken = IERC20(_collateralToken);
        gatewayRouter = _gatewayRouter;
        priceFeed = Oracle(_priceFeed);
        priceIdentifier = _priceIdentifier;
    }

    // Add a new question to the platform
    function addQuestion(string memory _questionText, uint256 _endTime, uint _correctAnswer) public returns (uint) {
        numQuestions++;
        questions[numQuestions] = Question(numQuestions, _questionText, _endTime, false, _correctAnswer);
        return numQuestions;
    }

    // Place a bet on a question
    function placeBet(uint _questionId, uint _answer) public {
        require(_answer >= 1 && _answer <= 4, "Invalid answer choice");
        require(block.timestamp < questions[_questionId].endTime, "Question has already expired");

        IERC20 token = collateralToken;
        uint256 amount = token.balanceOf(msg.sender);

        // Transfer tokens from sender to contract
        token.transferFrom(msg.sender, address(this), amount);

        // Add amount to sender's balance on question
        questions[_questionId].balances[_answer] += amount;
        questions[_questionId].bets[msg.sender][_answer] += amount;
    }

    // Resolve a question
    function resolveQuestion(uint _questionId) public {
        require(!questions[_questionId].resolved, "Question has already been resolved");

        questions[_questionId].resolved = true;

        // Check if the event has really happened
        require(checkEventHasOccurred(), "Event has not occurred yet");

        // Determine correct answer from UMA oracle
        uint _correctAnswer = getCorrectAnswerFromOracle();

        questions[_questionId].correctAnswer = _correctAnswer;

        // Calculate total pot and winnings
        IERC20 token = collateralToken;
        uint totalPot = token.balanceOf(address(this));
        uint totalWinnings = questions[_questionId].balances[_correctAnswer] * 95 / 100;

        for (uint i = 1; i <= 4; i++) {
            if (i != _correctAnswer) {
                uint totalBets = questions[_questionId].balances[i];
                if (totalBets > 0) {
                    // Calculate winnings for those who bet on the wrong answer
                    uint winnings = questions[_questionId].bets[msg.sender][i] * totalWinnings / totalBets;
                    token.transfer(msg.sender, winnings);
                }
            }
        }

        // Distribute winnings to winning bettors
        token.transfer(msg.sender, totalWinnings);

        // Calculate platform fee
        uint platformFee = totalPot * 4 / 100;
        token.transfer(owner(), platformFee);
}
// Get the correct answer from the UMA oracle
function getCorrectAnswerFromOracle() private view returns (uint) {
    bytes32 price = priceFeed.requestPrice(priceIdentifier, gatewayRouter);
    return uint(price) % 4 + 1;
}

// Check if the event has occurred using the UMA oracle
function checkEventHasOccurred() private view returns (bool) {
    bytes32 price = priceFeed.requestPrice(priceIdentifier, gatewayRouter);
    return uint(price) > 0;
}

function owner() public view returns (address) {
    return address(this);
}

