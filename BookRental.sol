// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BookRental {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    struct Book {
        string title;
        bool isAvailable;
        address borrower;
    }

    mapping(uint => Book) public books;
    uint public bookCount;

    // Events
    event BookRented(address indexed user, uint indexed bookId, string title);
    event BookReturned(address indexed user, uint indexed bookId);
    event BookRemoved(uint indexed bookId);

    // Add a new book (admin only)
    function addBook(string memory _title) public onlyAdmin {
        books[bookCount] = Book(_title, true, address(0));
        bookCount++;
    }

    // Remove a book (admin only)
    function removeBook(uint _bookId) public onlyAdmin {
        require(_bookId < bookCount, "Book does not exist.");
        books[_bookId].title = "deleted";
        books[_bookId].isAvailable = false;
        books[_bookId].borrower = address(0);
        emit BookRemoved(_bookId);
    }

    // Rent a book
    function rentBook(uint _bookId) public {
        require(_bookId < bookCount, "Book does not exist.");
        Book storage book = books[_bookId];
        require(book.isAvailable, "Book is already rented.");

        book.isAvailable = false;
        book.borrower = msg.sender;

        emit BookRented(msg.sender, _bookId, book.title);
    }

    // Return a book
    function returnBook(uint _bookId) public {
        require(_bookId < bookCount, "Book does not exist.");
        Book storage book = books[_bookId];
        require(book.borrower == msg.sender, "You did not rent this book.");

        book.isAvailable = true;
        book.borrower = address(0);

        emit BookReturned(msg.sender, _bookId);
    }

    // View book info
    function getBook(uint _bookId) public view returns (string memory, bool, address) {
        require(_bookId < bookCount, "Book does not exist.");
        Book memory book = books[_bookId];
        return (book.title, book.isAvailable, book.borrower);
    }
}
