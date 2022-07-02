// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Deploed to mumbai 0xd85719d7636891d0200d88D1CD2fec1BAE74E2B3
// Successfully verified contract ChainBattles on Etherscan.
// https://mumbai.polygonscan.com/address/0xd85719d7636891d0200d88D1CD2fec1BAE74E2B3#code

contract ChainBattles is ERC721URIStorage  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event NewHeroStats(
        uint256 level,
        uint256 speed,
        uint256 strength,
        uint256 life);

    struct Hero{
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life; 
    }

    mapping(uint256 => Hero) public tokenIdHero;

    constructor() ERC721 ("Chain Battles", "CBTLS"){

    }

    function generateCharacter(uint256 tokenId) public view returns(string memory){

        Hero memory hero = tokenIdHero[tokenId];


        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",hero.level.toString(),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",hero.speed.toString(),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",hero.strength.toString(),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",hero.life.toString(),'</text>',
            '</svg>'
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );

        return string(abi.encodePacked("data:application/json;base64,",Base64.encode(dataURI)));
    }

    function getSvgForTest(uint256 tokenId) public view returns (string memory){
         Hero memory hero = tokenIdHero[tokenId];
        bytes memory svg = 
           abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",hero.level.toString(),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",hero.speed.toString(),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",hero.strength.toString(),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",hero.life.toString(),'</text>',
            '</svg>'
        );

        return string(svg);
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdHero[newItemId] = getNewHero();
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

     function getNewHero() private pure returns(Hero memory){
        uint256 level = 0;
        uint256 speed = 10;
        uint256 strength = 10;
        uint256 life = 2;

        return Hero(
            level,
            speed,
            strength,
            life
        );
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use on exisiting Token");
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");

        tokenIdHero[tokenId] = getTrainedHero(tokenIdHero[tokenId]);

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getTrainedHero(Hero memory hero) private view returns(Hero memory){

        hero.level += 1;
        hero.speed += random(10);
        hero.speed += random(10);
        hero.strength += random(15);
        hero.life += random(5);
        
        return hero;
    }

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender))) % number;
    }
}