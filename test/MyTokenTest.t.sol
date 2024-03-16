// SPDX license identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    DeployMyToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);
        // myToken.transfer(alice, transferAmount); // using 'transfer' automatically sets the 'from' address

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        address to = address(0x1);
        uint256 transferAmount = 50;
        vm.prank(msg.sender);
        myToken.transfer(to, transferAmount);
        assertEq(myToken.balanceOf(to), transferAmount, "Transfer did not correctly modify the recipient's balance.");
    }

    function testTransferFrom() public {
        vm.startPrank(bob);
        myToken.approve(alice, 400);
        vm.stopPrank();

        vm.startPrank(alice);
        myToken.transferFrom(bob, alice, 400);
        assertEq(myToken.balanceOf(alice), 400, "alice should have 400 tokens after transferFrom.");
        vm.stopPrank();
    }
}
