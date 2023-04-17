// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/token.sol";

contract tokenTest is Test {
    SDUFECoin private token;
    using stdStorage for StdStorage;
    address internal constant receiver = address(1);

    function setUp() public {
        token = new SDUFECoin("SDUFECoinTest", "SDCT", 8);
    }

    function testFailNoMintPricePaid() public {
        token.mintTo(address(1));
    }
    
    function testSwapPaid() public {
        token.mintTo{value: 0.01 ether}(address(1));
    }
    

    function testFailMinPrice() public {
        token.mintTo{value: 0.000000001 ether}(address(1));
    }

    function testFailMaxsupply() public {
        token.mintTo{value: 0.015 ether}(address(1));
    }

    function testFailMaxsupplyUseCheat() public {
        uint256 slot = stdstore
            .target(address(token))
            .sig("totalSupply()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedTotalSupply = bytes32(abi.encode(1_000_000));
        vm.store(address(token), loc, mockedTotalSupply);
        token.mintTo{value: 0.00000001 ether}(address(1));
    }

    function testWithdrawalWorksAsOwner() public {
        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = payee.balance;
        token.mintTo{value: 0.0001 ether}(address(receiver));
        assertEq(address(token).balance, 0.0001 ether);
        uint256 tokenBalance = address(token).balance;
        token.withdrawPayments(payee);
        assertEq(payee.balance, priorPayeeBalance + tokenBalance);
    }

    function testWithdrawalFailsAsNotOwner() public {
        token.mintTo{value: token.MINT_PRICE()}(address(receiver));
        assertEq(address(token).balance, token.MINT_PRICE());
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        token.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }
}