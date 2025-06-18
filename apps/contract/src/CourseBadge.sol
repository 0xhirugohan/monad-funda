// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/**
 * @title CourseBadge
 * @dev Multi-token untuk berbagai badges dan certificates
 * Token types:
 * - Course completion certificates (non-fungible)
 * - Event attendance badges (fungible)
 * - Achievement medals (limited supply)
 * - Workshop participation tokens
 */
contract CourseBadge is ERC1155, AccessControl, Pausable, ERC1155Supply {
    // Role definitions
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Token ID ranges untuk organization
    uint256 public constant CERTIFICATE_BASE = 1000;
    uint256 public constant EVENT_BADGE_BASE = 2000;
    uint256 public constant ACHIEVEMENT_BASE = 3000;
    uint256 public constant WORKSHOP_BASE = 4000;
    
    // Token metadata structure
    struct TokenInfo {
        string name;
        string category;
        uint256 maxSupply;
        bool isTransferable;
        uint256 validUntil; // 0 = no expiry
        address issuer;
    }
    
    // TODO: Add mappings
    mapping(uint256 => TokenInfo) public tokenInfo;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _tokenCounters;
    
    // Track student achievements
    mapping(address => uint256[]) public studentBadges;
    mapping(uint256 => mapping(address => uint256)) public earnedAt; // Timestamp
    
    // Counter untuk generate unique IDs
    uint256 private _certificateCounter;
    uint256 private _eventCounter;
    uint256 private _achievementCounter;
    uint256 private _workshopCounter;

    error CertificateTypeDoesNotExist();
    error MaxSupplyExceeded();
    error StudentHasNoBadges();
    error CertificateIsExpired();

    constructor() ERC1155("") {
        // TODO: Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /**
     * @dev Create new certificate type
     * Use case: Mata kuliah baru atau program baru
     */
    function createCertificateType(
        string memory name,
        uint256 maxSupply,
        string memory uri
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        // TODO: Create new certificate type
        // 1. Generate ID: CERTIFICATE_BASE + _certificateCounter++
        uint256 certificateId = CERTIFICATE_BASE + _certificateCounter++;
        // 2. Store token info
        TokenInfo memory info = TokenInfo({
            name: name,
            category: "Certificate",
            maxSupply: maxSupply,
            isTransferable: false, // Certificates are not transferable
            validUntil: 0, // No expiry by default
            issuer: msg.sender
        });
        tokenInfo[certificateId] = info;
        _tokenCounters[certificateId] = 0;
        // 3. Set URI
        _tokenURIs[certificateId] = uri;
        // 4. Return token ID
        return certificateId;
    }

    /**
     * @dev Issue certificate to student
     * Use case: Student lulus mata kuliah
     */
    function issueCertificate(
        address student,
        uint256 certificateType,
        string memory additionalData
    ) public onlyRole(MINTER_ROLE) {
        // TODO: Mint certificate
        TokenInfo memory info = tokenInfo[certificateType];
        // 1. Verify certificate type exists
        if (bytes(info.name).length == 0) {
            revert CertificateTypeDoesNotExist();
        }
        // 2. Check max supply not exceeded
        uint256 mintedAmount = _tokenCounters[certificateType];
        if (mintedAmount >= info.maxSupply) {
            revert MaxSupplyExceeded();
        }
        // 3. Mint 1 token to student
        _tokenCounters[certificateType]++;
        _mint(student, certificateType, mintedAmount, bytes(additionalData));
        // 4. Record timestamp
        earnedAt[certificateType][student] = block.timestamp;
        // 5. Add to student's badge list
        studentBadges[student].push(certificateType);
    }

    /**
     * @dev Batch mint event badges
     * Use case: Attendance badges untuk peserta event
     */
    function mintEventBadges(
        address[] memory attendees,
        uint256 eventId,
        uint256 amount
    ) public onlyRole(MINTER_ROLE) {
        // TODO: Batch mint to multiple addresses
        // Use loop to mint to each attendee
        for (uint256 i = 0; i < attendees.length; i++) {
            address attendee = attendees[i];
            // 1. Generate badge ID
            uint256 badgeId = EVENT_BADGE_BASE + eventId;
            // 2. Mint badges
            _mint(attendee, badgeId, amount, "");
            // 3. Record participation
            studentBadges[attendee].push(badgeId);
        }
    }

    /**
     * @dev Set metadata URI untuk token
     */
    function setTokenURI(uint256 tokenId, string memory newuri) 
        public onlyRole(URI_SETTER_ROLE) 
    {
        // TODO: Store custom URI per token
        _tokenURIs[tokenId] = newuri;
    }

    /**
     * @dev Get all badges owned by student
     */
    function getStudentBadges(address student) 
        public view returns (uint256[] memory) 
    {
        // TODO: Return array of token IDs owned by student
        return studentBadges[student];
    }

    /**
     * @dev Verify badge ownership dengan expiry check
     */
    function verifyBadge(address student, uint256 tokenId) 
        public view returns (bool isValid, uint256 earnedTimestamp) 
    {
        // TODO: Check ownership and validity
        // 1. Check balance > 0
        if (balanceOf(student, tokenId) == 0) {
            revert StudentHasNoBadges();
        }
        // 2. Check not expired
        isValid = tokenInfo[tokenId].validUntil > block.timestamp;
        // 3. Return status and when earned
        return (isValid, earnedAt[tokenId][student]);
    }

    /**
     * @dev Pause all transfers
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Override transfer to check transferability and pause
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        // TODO: Check transferability for each token
        for (uint i = 0; i < ids.length; i++) {
            if (from != address(0) && to != address(0)) { // Not mint or burn
                require(tokenInfo[ids[i]].isTransferable, "Token not transferable");
            }
        }
        
        super._update(from, to, ids, amounts);
    }

    /**
     * @dev Override to return custom URI per token
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        // TODO: Return stored URI for token
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Check interface support
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Achievement System Functions
    
    /**
     * @dev Grant achievement badge
     * Use case: Dean's list, competition winner, etc
     */
    function grantAchievement(
        address student,
        string memory achievementName,
        uint256 rarity // 1 = common, 2 = rare, 3 = legendary
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        // TODO: Create unique achievement NFT
        // Generate achievement ID
        uint256 achievementId = ACHIEVEMENT_BASE + _achievementCounter++;
        // Set limited supply based on rarity
        TokenInfo memory info = TokenInfo({
            name: achievementName,
            category: "Achievement",
            maxSupply: rarity == 1 ? 1000 : (rarity == 2 ? 100 : 10), // Example limits
            isTransferable: false, // Achievements can't be traded
            validUntil: 0, // No expiry
            issuer: msg.sender
        });
        // Mint to deserving student
        tokenInfo[achievementId] = info;
        _mint(student, achievementId, 1, "");

        return achievementId;
    }

    /**
     * @dev Create workshop series dengan multiple sessions
     */
    function createWorkshopSeries(
        string memory seriesName,
        uint256 totalSessions
    ) public onlyRole(MINTER_ROLE) returns (uint256[] memory) {
        // TODO: Create multiple related tokens
        uint256[] memory workshopIDs;
        for (uint256 i = 0; i < totalSessions; i++) {
            uint256 workshopId = WORKSHOP_BASE + _workshopCounter++;
            TokenInfo memory info = TokenInfo({
                name: seriesName,
                category: "Workshop",
                maxSupply: totalSessions,
                isTransferable: false,
                validUntil: 0,
                issuer: msg.sender
            });
            tokenInfo[workshopId] = info;
        }

        // Return array of token IDs for each session
        return workshopIDs;
    }
}