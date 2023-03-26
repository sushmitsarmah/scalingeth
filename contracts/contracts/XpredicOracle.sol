// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uma/core/contracts/oracle/interfaces/FinderInterface.sol";
import "@uma/core/contracts/oracle/interfaces/OptimisticOracleV2Interface.sol";
import "@uma/core/contracts/oracle/implementation/Constants.sol";

contract XpredicOracle {
    using SafeERC20 for IERC20;

    // Struct for a question.
    struct Question {
        string text;
        uint256 expiryTime;
        bool isClosed;
        bool isAnswerYes;
        uint256 yesStake;
        uint256 noStake;
        mapping(address => uint256) yesStakers;
        mapping(address => uint256) noStakers;
    }

    // Contract state variables.
    IERC20 public stakeToken;
    FinderInterface public finder;
    bytes32 public priceIdentifier = "YES_OR_NO_QUERY";
    bytes public customAncillaryData;
    uint256 public requestTimestamp;

    Question[] public questions;

    event QuestionCreated(
        uint256 indexed questionId,
        string text,
        uint256 expiryTime
    );
    event QuestionAnswered(uint256 indexed questionId, bool indexedisAnswerYes);
    event QuestionClosed(uint256 indexed questionId);
    event Staked(
        uint256 indexed questionId,
        address indexed staker,
        bool indexed isYes,
        uint256 amount
    );

    constructor(
        IERC20 _stakeToken,
        FinderInterface _finder,
        bytes memory _customAncillaryData
    ) {
        stakeToken = _stakeToken;
        finder = _finder;
        customAncillaryData = _customAncillaryData;
        requestTimestamp = block.timestamp;
    }

    function createQuestion(
        string calldata text,
        uint256 expiryTime
    ) external returns (uint256) {
        require(
            expiryTime > block.timestamp,
            "Expiry time should be in the future."
        );

        uint256 questionId = questions.length;
        questions.push(
            Question({
                text: text,
                expiryTime: expiryTime,
                isClosed: false,
                isAnswerYes: false,
                yesStake: 0,
                noStake: 0
            })
        );

        emit QuestionCreated(questionId, text, expiryTime);
        return questionId;
    }

    function stake(uint256 questionId, bool stakeYes, uint256 amount) external {
        require(!questions[questionId].isClosed, "Question is closed.");
        require(
            block.timestamp < questions[questionId].expiryTime,
            "Question has expired."
        );

        stakeToken.safeTransferFrom(msg.sender, address(this), amount);

        if (stakeYes) {
            questions[questionId].yesStake += amount;
        } else {
            questions[questionId].noStake += amount;
        }

        emit Staked(questionId, msg.sender, stakeYes, amount);
    }

    function closeQuestion(uint256 questionId) external {
        require(
            block.timestamp >= questions[questionId].expiryTime,
            "Question has not expired yet."
        );
        require(!questions[questionId].isClosed, "Question is already closed.");

        OptimisticOracleV2Interface optimisticOracle = getOptimisticOracle();
        require(
            optimisticOracle.hasPrice(
                address(this),
                priceIdentifier,
                requestTimestamp,
                customAncillaryData
            ),
            "Price not available."
        );

        int256 oraclePrice = optimisticOracle.getPrice(
            address(this),
            priceIdentifier,
            requestTimestamp,
            customAncillaryData
        );

        // The oraclePrice should be either 0 or 1. If it's 1, set isAnswerYes to true.
        questions[questionId].isAnswerYes = oraclePrice == 1;
        questions[questionId].isClosed = true;

        emit QuestionClosed(questionId);
    }

    function getOptimisticOracle()
        internal
        view
        returns (OptimisticOracleV2Interface)
    {
        return
            OptimisticOracleV2Interface(
                finder.getImplementationAddress("OptimisticOracleV2")
            );
    }

    function getQuestion(
        uint256 questionId
    ) external view returns (Question memory) {
        return questions[questionId];
    }
}
