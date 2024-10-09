// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";


interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;
    address public user1 = address(0x123);
    address public user2 = address(0x456);

    event Transfer(address from, address to, uint256 value);
    event Approval(address from, address to, uint256 value);

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.deal(user1, 1 ether); // Giving some initial balance to user1 for transactions
        vm.deal(user2, 1 ether); // Giving some initial balance to user2 for transactions
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowance() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.approve(user1, amount);

        assertEq(ourToken.allowance(msg.sender, user1), amount);
    }

    function testTransfer() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.transfer(user1, amount);

        assertEq(ourToken.balanceOf(user1), amount);
        assertEq(ourToken.balanceOf(msg.sender), deployer.INITIAL_SUPPLY() - amount);
    }

    function testTransferFrom() public {
        uint256 amount = 500 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        ourToken.approve(user1, amount);

        vm.prank(user1);
        ourToken.transferFrom(msg.sender, user2, amount);

        assertEq(ourToken.balanceOf(user2), amount);
        assertEq(ourToken.allowance(msg.sender, user1), 0);
    }

    function testFailTransferExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.prank(msg.sender);
        ourToken.transfer(user1, amount); // This should fail
    }

    function testFailApproveExceedsBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;
        vm.prank(msg.sender);
        vm.expectRevert();
        ourToken.approve(user1, amount); // This should fail
    }

    /*function testTransferEvent() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        vm.expectEmit(true, true, false, true);
        emit Transfer(msg.sender, user1, amount);
        ourToken.transfer(user1, amount);
    }

    function testApprovalEvent() public {
        uint256 amount = 1000 * 10 ** 18; // Example amount
        vm.prank(msg.sender);
        vm.expectEmit(true, true, false, true);
        emit Approval(msg.sender, user1, amount);
        ourToken.approve(user1, amount);
    }*/
}