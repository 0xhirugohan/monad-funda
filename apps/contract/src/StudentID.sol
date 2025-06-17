// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StudentID
 * @dev NFT-based student identity card
 * Features:
 * - Auto-expiry after 4 years
 * - Renewable untuk active students
 * - Contains student metadata
 * - Non-transferable (soulbound)
 */
contract StudentID is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;
    
    struct StudentData {
        string nim;
        string name;
        string major;
        uint256 enrollmentYear;
        uint256 expiryDate;
        bool isActive;
        uint8 semester;
    }
    
    // TODO: Add mappings
    mapping(uint256 => StudentData) public studentData;
    mapping(string => uint256) public nimToTokenId; // Prevent duplicate NIM
    mapping(address => uint256) public addressToTokenId; // One ID per address
    
    // Events
    event StudentIDIssued(
        uint256 indexed tokenId, 
        string nim, 
        address student,
        uint256 expiryDate
    );
    event StudentIDRenewed(uint256 indexed tokenId, uint256 newExpiryDate);
    event StudentStatusUpdated(uint256 indexed tokenId, bool isActive);
    event ExpiredIDBurned(uint256 indexed tokenId);

    // Errors
    error NIMRegistered();
    error AddressRegistered();
    error TokenDoesNotExist();
    error StudentIsActive();
    error TokenIsNonTransferable();
    error NotOwner();

    constructor() ERC721("Student Identity Card", "SID") Ownable(msg.sender) {}

    /**
     * @dev Issue new student ID
     * Use case: New student enrollment
     */
    function issueStudentID(
        address to,
        string memory nim,
        string memory name,
        string memory major,
        string memory uri
    ) public onlyOwner {
        // TODO: Implement ID issuance
        // Hints:
        // 1. Check NIM tidak duplicate (use nimToTokenId)
        if (nimToTokenId[nim] > 0) {
            revert NIMRegistered();
        }
        // 2. Check address belum punya ID (use addressToTokenId)
         if (addressToTokenId[to] > 0) {
            revert AddressRegistered();
         }
        // 3. Calculate expiry (4 years from now)
        uint256 expiryDate = block.timestamp + (365 days * 4) + 1 days;
        // 4. Mint NFT
        uint256 _tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, _tokenId);
        // 5. Set token URI (foto + metadata)
        _setTokenURI(_tokenId, uri);

        // 6. Store student data
        StudentData memory _studentData = StudentData(
            nim,
            name,
            major,
            2025,
            expiryDate,
            true,
            1
        );
        studentData[_tokenId] = _studentData;

        // 7. Update mappings
        nimToTokenId[nim] = _tokenId;
        addressToTokenId[to] = _tokenId;

        // 8. Emit event
        emit StudentIDIssued(
            _tokenId,
            nim,
            to,
            expiryDate
        );
    }
    
    /**
     * @dev Renew student ID untuk semester baru
     */
    function renewStudentID(uint256 tokenId) public onlyOwner {
        // TODO: Extend expiry date
        StudentData memory _studentData = studentData[tokenId];
        // Check token exists
        if (bytes(_studentData.nim).length == 0) {
            revert TokenDoesNotExist();
        }
        // Check student is active
        if (_studentData.isActive == true) {
            revert StudentIsActive();
        }
        // Add 6 months to expiry
        _studentData.expiryDate += 6 * 30 days; // 6 months
        // Update semester
        _studentData.semester += 1;
        studentData[tokenId] = _studentData;
        // Emit renewal event
        emit StudentIDRenewed(
            tokenId,
            _studentData.expiryDate
        );
    }
    
    /**
     * @dev Update student status (active/inactive)
     * Use case: Cuti, DO, atau lulus
     */
    function updateStudentStatus(uint256 tokenId, bool isActive) public onlyOwner {
        if (tokenId > _nextTokenId) {
            revert TokenDoesNotExist();
        }
        // TODO: Update active status
        studentData[tokenId].isActive = isActive;
        emit StudentStatusUpdated(tokenId, isActive);
        // If inactive, maybe reduce privileges
    }
    
    /**
     * @dev Burn expired IDs
     * Use case: Cleanup expired cards
     */
    function burnExpired(uint256 tokenId) public {
        // TODO: Allow anyone to burn if expired
        // Check token exists
        if (tokenId > _nextTokenId) {
            revert TokenDoesNotExist();
        }

        // Check if expired (block.timestamp > expiryDate)
        StudentData memory _studentData = studentData[tokenId];
        if (_studentData.expiryDate > block.timestamp) {
            revert StudentIsActive();
        }

        address owner = ownerOf(tokenId);

        // Burn token
        _burn(tokenId);
        // Clean up mappings
        delete studentData[tokenId];
        delete nimToTokenId[_studentData.nim];
        delete addressToTokenId[owner];

        // Emit event
        emit ExpiredIDBurned(tokenId);
    }
    
    /**
     * @dev Check if ID is expired
     */
    function isExpired(uint256 tokenId) public view returns (bool) {
        // TODO: Return true if expired
        return studentData[tokenId].expiryDate < block.timestamp;
    }
    
    /**
     * @dev Get student info by NIM
     */
    function getStudentByNIM(string memory nim) public view returns (
        address owner,
        uint256 tokenId,
        StudentData memory data
    ) {
        // TODO: Lookup student by NIM
        uint256 _tokenId = nimToTokenId[nim];
        StudentData memory student = studentData[_tokenId];
        return (ownerOf(_tokenId), _tokenId, student);
    }

    /**
     * @dev Override transfer functions to make non-transferable
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        // TODO: Make soulbound (non-transferable)
        // Only allow minting (from == address(0)) and burning (to == address(0))
        // require(from == address(0) || to == address(0), "SID is non-transferable");
        if (to != address(0)) {
            revert TokenIsNonTransferable();
        }
        // super._beforeTokenTransfer(from, to, tokenId, batchSize);
        return super._update(to, tokenId, auth);
    }

    // Override functions required untuk multiple inheritance
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public override {
        if (ownerOf(tokenId) != msg.sender) {
            revert NotOwner();
        }

        // TODO: Clean up student data when burning
        delete nimToTokenId[studentData[tokenId].nim];
        delete addressToTokenId[ownerOf(tokenId)];
        delete studentData[tokenId];

        _burn(tokenId);
    }
}