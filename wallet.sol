pragma solidity 0.7.5;
pragma abicoder v2;

contract MultiSigWallet {
      
   event depositComplete(uint amount, address indexed sender);
   event requestPending(uint amount, address indexed sender, address indexed recipient);
   event transactionSent(uint amount, address indexed recipient);
   
     address[] allOwners;
     uint balance;
     uint ConfirmationsRequired;
     mapping(address => bool) checkOwner;
     mapping(uint => mapping(address => bool)) isConfirmed;
     
     struct Transfer {
     address payable recipient;
     uint amount;
     uint transferId;
     uint confirmationCount;
     bool happened;
        }
        
     modifier onlyOwner() {
         bool owner = false;
         for(uint i = 0; i < allOwners.length;i++){
         if(allOwners[i] == msg.sender){
             owner = true;
             
          
            
        
         _;
         }
     }
        require(owner == true, "Only owners");
     }
     
     modifier notConfirmed(uint transferId) {
        require(!isConfirmed[transferId][msg.sender], "Transaction already confirmed");
        _;
    }
     
     constructor(address[] memory _allOwners, uint _ConfirmationsRequired){
           allOwners = _allOwners;
           ConfirmationsRequired = _ConfirmationsRequired;
    
     }

     
     function transactionRequest(address payable recipient, uint amount) public payable {
         require(balance >= amount);
         trRequests.push(Transfer(recipient,amount,0,0,false));
         emit requestPending(msg.value, msg.sender, recipient);
     
     }
     function signRequest(uint transferId) public onlyOwner {
    
         Transfer storage transfer = trRequests[transferId];
         transfer.confirmationCount += 1;
         isConfirmed[transferId][msg.sender] = true;
         
        if(transfer.confirmationCount >= ConfirmationsRequired){
            trRequests[transferId].recipient.transfer(trRequests[transferId].amount); 
            balance = balance - trRequests[transferId].amount;
         emit transactionSent(trRequests[transferId].amount, trRequests[transferId].recipient);
     }
     }

    Transfer[] trRequests;
    
    function deposit() public payable returns (uint) {
        balance += msg.value;
        emit depositComplete(msg.value, msg.sender);
        return balance;
    }
    
    function currentBalance() public view returns (uint) {
        return balance;
    }

    function minimumSigns() public view returns (uint) {
    return ConfirmationsRequired;
    }
    function TotalRequestedTransfers() public view returns (uint) {
    return trRequests.length;    
    }
}