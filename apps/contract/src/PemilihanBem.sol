// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PemilihanBEM {
    struct Kandidat {
        string nama;
        string visi;
        uint256 suara;
    }
    
    Kandidat[] public kandidat;
    mapping(address => bool) public sudahMemilih;
    mapping(address => bool) public pemilihTerdaftar;
    
    uint256 public waktuMulai;
    uint256 public waktuSelesai;
    address public admin;
    
    event VoteCasted(address indexed voter, uint256 kandidatIndex);
    event KandidatAdded(string nama);
    
    modifier onlyDuringVoting() {
        require(
            block.timestamp >= waktuMulai && 
            block.timestamp <= waktuSelesai, 
            "Voting belum dimulai atau sudah selesai"
        );
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Bukan admin");
        _;
    }

    modifier onlyRegisteredVoter() {
        require(pemilihTerdaftar[msg.sender], "Bukan pemilih terdaftar");
        _;
    }
    
    // TODO: Implementasikan add candidate function
    function addCandidate(string memory _nama, string memory _visi) public onlyAdmin {
        kandidat.push(Kandidat(_nama, _visi, 0));
    }

    // TODO: Implementasikan vote function
    function vote(uint256 kandidatIndex) public onlyRegisteredVoter {
        require(block.timestamp >= waktuMulai && block.timestamp <= waktuSelesai, "belum waktunya");

        sudahMemilih[msg.sender] = true;
        kandidat[kandidatIndex].suara += 1;

        emit VoteCasted(msg.sender, kandidatIndex);
    }

    // TODO: Implementasikan get results function
}