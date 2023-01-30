pragma solidity >=0.6.0 <=0.8.0;

 import "@openzeppelin/contracts/access/Ownable.sol";
 import "./Token.sol";
 
contract CarRental is Ownable {
   
    string public name = "Car Rental";
    Token token; //Reference to deployed ERC20 Token contract
    address public payable wallet; //Address of the owner of Car Rental Shop
    uint8 collateralPremium=20; // discount % to be applied to standard rate for PREMIUM "collateralized customers"
    uint8 tokenConversionRate = 2; //conversion rate between Ether and Token, i.e. 1 Ether = 2 Token
    uint rate=1; //amount of wei to be charged per second (i.e. "standard rate")
    uint etherMinBalance=1; //minimum amount of ETH required to start Car rental
    uint tokenMinBalance= 1; //minimum amount of Tokens required to start Car rental   
    uint etherCollateralThreshold=1; //Threshold amount of ETH required to get PREMIUM "collateralized" rate
    uint tokenCollateralThreshold=1; //Threshold amount of Tokens required to get PREMIUM "collateralized" rate
    uint public no_of_agreement = 0; //agreement no.
    
    struct Car {                
        uint8 CarId; // Id of the car
        string carbrand;  // characteristcs of the car
        string color;
        string type;
        uint rent_per_hour;
        uint securityDeposit;
        bool notAvailable;
        bool damage;
        address customer; 
    }

    struct Customer { 
        uint8 CarId; // Id of rented Car       
        bool isRenting; // in order to start renting, `isRenting` should be false
        uint rate; //customer's applicable rental rate
        uint etherBalance; // customer internal ether account
        uint tokenBalance; // customer internal token account
        uint startTime; //starting time of the rental (in seconds)
        uint etherDebt; // amount in ether owed to Car Rental Shop
    }    

    mapping (address => Customer) customers ; // Record with customers data (i.e., balance, startTie, debt, rate, etc)
    mapping (uint8 => Car) Cars ; // Stock of Cars    

    modifier onlyCompany() {
        require(msg.sender == wallet, "Only company can access this");
        _;
    }
   
    modifier OnlyWhileNoPending(){
        require(customers[msg.sender].etherDebt == 0, "Not allowed to rent if debt is pending");
        _;
    }

    modifier OnlyWhileAvailable(uint8 _CarId){
        require(!Cars[_CarId].notAvailable, "Car not available");
        _;
    }

    modifier OnlyOneRental(){
        require(!customers[msg.sender].isRenting, "Another car rental in progress. Finish current rental first");
        _;
    }

    modifier EnoughRentFee(){
        require(customers[msg.sender].etherBalance >= etherMinBalance || customers[msg.sender].tokenBalance >= tokenMinBalance, "Not enough funds in your account");
        _;
    }
    
    modifier sameCustomer(uint8 _CarId) {
        require(msg.sender == Cars[_CarId].customer, "No previous agreement found with you & company");
        _;
    }
    
    modifier Notdamage(uint8 _CarId){
        require(!Cars[_CarId].damage, "Car damage");
        _;
    }


    event RentalStart(address _customer, uint _startTime, uint _rate, uint8 _CarId, uint _blockId);
    event RentalStop(address _customer, uint _stopTime, uint _totalAmount, uint _totalDebt, uint _blockId);
    event FundsReceived(address _customer, uint _etherAmount, uint _tokenAmount);
    event FundsWithdrawned(address _customer);
    event FundsReturned(address _customer, uint _etherAmount, uint _tokenAmount);
    event BalanceUpdated(address _customer, uint _etherAmount, uint _tokenAmount);
    event TokensReceived(address _customer, uint _tokenAmount);    
    event DebtUpdated (address _customer, uint _origAmount, uint _pendingAmount, uint _debitedAmount, uint _tokenDebitedAmount);
    event TokensBought (address _customer,uint _etherAmount, uint _tokenAmount);

}
