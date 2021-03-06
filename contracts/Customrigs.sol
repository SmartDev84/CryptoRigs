// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Customrigs is ERC721Enumerable, Ownable {

    using Strings for uint256;

    string _baseTokenURI;
    uint256 private BUYABLE = 20;
    uint256 private PRICE = 0.015 ether; //0.015 ETH;
    address private finance = 0xE8912eDc897E994319C6C857E54F0a964bB87115;
    uint public constant MAX_ENTRIES = 10000;

    uint256 public sold;

	uint256 public startTime;
    uint256[MAX_ENTRIES] internal availableIds;
    
    function setStartTime(uint256 _start) external onlyOwner {
    //    require(block.timestamp < startTime || startTime == 0);
    //    require(_start > block.timestamp);
        startTime = _start;
	}

   	function _getNewId(uint256 _totalMinted) internal returns(uint256 value) {
		uint256 remaining = MAX_ENTRIES - _totalMinted;
        uint rand = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, remaining))) % remaining;
		value = 0;
		// if array value exists, use, otherwise, use generated random value
		if (availableIds[rand] != 0)
			value = availableIds[rand];
		else
			value = rand;
		// store remaining - 1 in used ID to create mapping
		if (availableIds[remaining - 1] == 0)
			availableIds[rand] = remaining - 1;
		else
			availableIds[rand] = availableIds[remaining - 1];
        value += 1;
	} 

    function mint(uint256 _amount) external payable {
        require(block.timestamp >= startTime && startTime != 0, "Computer: Minting not started");
        uint256 amountForNextPrice = 10 - (sold%10);
        uint256 estimatedPrice = 0;
        if (_amount > amountForNextPrice)
            estimatedPrice = PRICE * amountForNextPrice + PRICE * 120 / 100 * (_amount-amountForNextPrice);
        else
            estimatedPrice = PRICE * _amount;
		require(msg.value >= estimatedPrice, "Computer: incorrect price");
        uint256 tokenCount = balanceOf(msg.sender);
		require(tokenCount + _amount <= BUYABLE, "Computer: Buyable amount has been reached");
        payable(finance).transfer(address(this).balance);
        for (uint256 i = 0; i < _amount; i++)
		    _mint(msg.sender, _getNewId(sold + i));
		sold += _amount;
        if (_amount >= amountForNextPrice)
            PRICE = PRICE * 120 / 100;
    }

    function getPrice() public view returns (uint256){
        return PRICE;
    }

    function setPrice(uint256 _newPrice) public onlyOwner() {
        PRICE = _newPrice;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

}