// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Donation {
    address public owner;

    struct Gift {
        address donor;
        uint256 amount;
        uint256 timestamp;
    }

    Gift[] public gifts;
    mapping(address => uint256) public donated;

    event Donated(address indexed donor, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Accept native CELO sent directly
    receive() external payable {
        _record(msg.sender, msg.value);
    }

    // Fallback for unknown calls
    fallback() external payable {
        _record(msg.sender, msg.value);
    }

    // Donate via function call
    function donate() external payable {
        require(msg.value > 0, "send some CELO");
        _record(msg.sender, msg.value);
    }

    function _record(address _from, uint256 _amount) internal {
        gifts.push(Gift(_from, _amount, block.timestamp));
        donated[_from] += _amount;
        emit Donated(_from, _amount);
    }

    function totalGifts() external view returns (uint256) {
        return gifts.length;
    }

    function getGift(uint256 index)
        external
        view
        returns (address donor, uint256 amount, uint256 timestamp)
    {
        require(index < gifts.length, "out of range");
        Gift memory g = gifts[index];
        return (g.donor, g.amount, g.timestamp);
    }

    function withdraw(address payable _to) external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "no funds");
        (bool ok, ) = _to.call{value: bal}("");
        require(ok, "transfer failed");
        emit Withdrawn(_to, bal);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "zero address");
        owner = _newOwner;
    }
}
