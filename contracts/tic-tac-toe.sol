// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

/**
 * @title TicTacToe
 * @dev play simple tic-tac-toe game
 */
contract TicTacToe {

    address private owner;
    address public player1;
    address public  player2;
    address public currentPlayer;
    address public  winner;
    uint8[3][3] public board; // 0 = empty, 1 = player1, 2 = player2
    bool public gameActive;

    // event for EVM logging
    event GameStarted(address indexed player1, address indexed player2);
    event MoveMade(address indexed player, uint8 row, uint8 col);
    event GameWon(address indexed winner);
    event GameDraw();

    modifier isPlayer() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == player1 || msg.sender == player2, "Not a player!");
        _;
    }

    modifier gameIsActive() {
        require(gameActive, "Game is not active");
        _;
    }

    constructor(address _player2) {
        player1 = msg.sender;
        player2 = _player2;
        currentPlayer = player1;
        gameActive = true;
        emit GameStarted(player1, player2);
    }

    function makeMove(uint8 row, uint8 col) external isPlayer gameIsActive {
        require(row < 3 && row >= 0 && col < 3 && col >= 0, "Invalid coordinates");
        require(board[row][col] == 0, "Position already taken");
        require(msg.sender == currentPlayer, "Not your turn");

        board[row][col] = msg.sender == player1 ? 1 : 2;
        emit MoveMade(msg.sender, row, col);

        if (checkWinner(row, col)) {
            winner = currentPlayer;
            gameActive = false;
            if (board[row][col] == 1) {
                console.log("player 1 is the winner");
            } else {
                console.log("player 2 is the winner");
            }
            emit GameWon(winner);
        } else if (isBoardFull()) {
            gameActive = false;
            console.log("Its a tie!");
            emit GameDraw();
        } else {
            currentPlayer = currentPlayer == player1 ? player2 : player1;
        }

        printBoard();
    }

    function checkWinner(uint8 row, uint8 col) internal view returns (bool) {
        uint8 playerSymbol = board[row][col];

        // row
        if (board[row][0] == playerSymbol && board[row][1] == playerSymbol && board[row][2] == playerSymbol) {
            return true;
        }

        // column
        if (board[0][col] == playerSymbol && board[1][col] == playerSymbol && board[2][col] == playerSymbol) {
            return true;
        }

        // diagonal
        if (row == col && board[0][0] == playerSymbol && board[1][1] == playerSymbol && board[2][2] == playerSymbol) {
            return true;
        }

        // other diagonal
        if (row + col == 2 && board[0][2] == playerSymbol && board[1][1] == playerSymbol && board[2][0] == playerSymbol) {
            return true;
        }

        return false;
    }

    function isBoardFull() internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                if (board[i][j] == 0) {
                    return false;
                }
            }
        }
        return true;
    }

    function printBoard() public view returns (string memory) {
        bytes memory output;
        
        for (uint8 i = 0; i < 3; i++) {
            bytes memory row;
            for (uint8 j = 0; j < 3; j++) {
                if (board[i][j] == 0) {
                    row = abi.encodePacked(row, "_");
                } else if (board[i][j] == 1) {
                    row = abi.encodePacked(row, "X");
                } else if (board[i][j] == 2) {
                    row = abi.encodePacked(row, "O");
                }
                if (j < 2) {
                    row = abi.encodePacked(row, "|");
                }
            }
            console.log(string(row));
            output = abi.encodePacked(output, row);

            if (i < 2) {
                output = abi.encodePacked(output, "\n-----\n");
            }
        }
        return string(output);
    }
} 
