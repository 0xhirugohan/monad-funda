// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract SistemAkademik {
    struct Mahasiswa {
        string nama;
        uint256 nim;
        string jurusan;
        uint256[] nilai;
        bool isActive;
    }
    
    mapping(uint256 => Mahasiswa) public mahasiswa;
    mapping(address => bool) public authorized;
    uint256[] public daftarNIM;
    
    event MahasiswaEnrolled(uint256 nim, string nama);
    event NilaiAdded(uint256 nim, uint256 nilai);
    
    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Tidak memiliki akses");
        _;
    }
    
    constructor() {
        authorized[msg.sender] = true;
    }
    
    // TODO: Implementasikan enrollment function
    function enrollment(string memory _nama, string memory _jurusan, uint256 _nim) public onlyAuthorized {
        daftarNIM.push(_nim);
        mahasiswa[_nim] = Mahasiswa({
            nama: _nama,
            nim: _nim,
            jurusan: _jurusan,
            nilai: new uint256[](0),
            isActive: true
        });

        emit MahasiswaEnrolled(_nim, _nama);
    }

    // TODO: Implementasikan add grade function
    function addGrade(uint256 _nim, uint256 _nilai) public onlyAuthorized {
        mahasiswa[_nim].nilai.push(_nilai);
        emit NilaiAdded(_nim, _nilai);
    }

    // TODO: Implementasikan get student info function
    function getStudent(uint256 _nim) public view returns (Mahasiswa memory) {
        return mahasiswa[_nim];
    }
}