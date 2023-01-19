//by jnbez 
//need to find point calulate funtion ;


pragma solidity ^0.8.7;
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Users   {
    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal nftFloorPriceFeed;


   struct user  {
        address user_address ;
        uint256 user_likes;
        uint256  user_Followers ;
        uint256 user_Following ;
        uint256 user_NFTs ;
        uint256 user_totalprice ;
        uint256 user_inverstors ;
        uint256 user_share ;
        uint256 user_comment ;
        uint256 user_visit ;
        uint256 user_point ;
        uint256 user_stock_price ;

   }

 IERC20 public INA_contact;
 IERC721 public nfts_contract ;
 address INA_TOKEN ;
 uint256 contract_INA_balacne ;
mapping(address => mapping(address => uint256)) public stock_owned_balance;
mapping(address => mapping(address => uint256)) public stock_owned_balance_To_sell;

 user [] public users ;
mapping(address => uint256) public  user_id;

constructor(IERC20 _erc20_contract_address,address _INA_TOKEN,IERC721 _nfts,address _nfts_address) {
        priceFeed = AggregatorV3Interface( _INA_TOKEN);
        nftFloorPriceFeed = AggregatorV3Interface(_nfts_address);
        INA_contact = _erc20_contract_address;
        nfts_contract = _nfts ;
    }
     // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(INA_contact.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }
    //@test function NFT_getLatestPrice() public view returns (int) {
    //     (  , int nftFloorPrice , ,,) = nftFloorPriceFeed.latestRoundData();

    //     return nftFloorPrice; }
 
  //@Test function getSmartContractBalance() external view returns(uint) {
//         return INA_contact.balanceOf(address(this));
//     }



  event log_create_user(address _user_address ,uint256 _user_likes,uint256  _user_Followers ,uint256 _user_Following ,uint256 _nfts
        ,uint256 _user_totalprice ,uint256 _user_inverstors ,uint256 _user_share ,
        uint256 _user_comment ,uint256 _user_visit , uint256 user_point, uint256 _user_stock_price) ;

function create_user(address _user_address,uint256 _user_likes,uint256  _user_Followers ,uint256 _user_Following ,
        uint256 _user_totalprice ,uint256 _user_inverstors ,uint256 _user_share ,
        uint256 _user_comment ,uint256 _user_visit,uint256 user_point,uint256 _user_stock_price,uint256 _start_stock ) 
        public  {
            // only one account for one address
        require(user_id[msg.sender]<=0,"address had account ");
        user memory _user = user( _user_address,_user_likes, _user_Followers,_user_Following,0,_user_totalprice,_user_inverstors,
                      _user_share, _user_comment, _user_visit, user_point,_user_stock_price);

        user_id[msg.sender] =users.length+1;
        stock_owned_balance[_user_address][_user_address]=1;
        emit log_create_user( _user_address,_user_likes, _user_Followers,_user_Following,0,_user_totalprice,_user_inverstors,
        _user_share, _user_comment, _user_visit, user_point,_user_stock_price);
        users.push(_user); // push to the array

 }
   
function INA_getLatestPrice() public view returns (uint256) {
        ( ,int price, , ,
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
 
   function get_userID ( address _useraddress) public view returns (uint256){
        require(user_id[_useraddress]>=0,"Account did not Exist  ");

       return user_id[_useraddress] ;
   }
   
function vist(address _user_address) public payable   returns  (uint256,uint256,uint256,
  uint256,uint256,uint256,uint256,uint256,uint256,uint256)  
  {
    uint256 user_ID =get_userID(_user_address);
    require(user_ID>0,"user did not exist");
    //increase visiters of the user by 1
    users[user_ID].user_visit = users[user_ID].user_visit+1;

 user memory _user = users[user_ID];
        return (
            _user.user_likes,
            _user.user_Followers,
            _user.user_Following,
            _user.user_NFTs,
            _user.user_totalprice,
            _user.user_inverstors,
            _user. user_share,
            _user.user_comment,
            _user.user_visit,
            _user.user_point 

        );

}

//  function get_user_nfts()  payable public returns(uint256){
//  require(user_id[msg.sender]>=0,"Account did not Exist  ");
//         uint256 user_ID =get_userID(msg.sender);
//         users[user_ID].user_NFTs = nfts_contract.balanceOf(msg.sender) ;
//         return users[user_ID].user_NFTs ;
//  }

//get balance of INA_stocks for caller
// 1 million points will finally get 2000 tokens
function number_of_INA_stocks  () public view returns (uint256){
        require(user_id[msg.sender]>=0,"Account did not Exist  ");
        uint256 user_ID =get_userID(msg.sender);
        uint256 _user_points = users[user_ID].user_point  ;
                 uint256 _number_of_INA = _user_points/500;
        return _number_of_INA ;
    }



    function Credit_price(address _user_address) public view returns (uint256){
        require(user_id[msg.sender]>=0,"Account did not Exist  ");
        uint256 user_ID =get_userID(_user_address);
        require(user_ID>0,"user did not exist");

        uint256 a = users[user_ID].user_point ;
        uint256 b = 1;//@test INA_getLatestPrice()
        uint256 c = number_of_INA_stocks();
        uint256 _Credit_price = a*b*c;
        return _Credit_price;
         //users[ _userID].score.mul(getLatestPrice());
    }


    /// ???????????????????????
            //function to determine  points for users  ? 

            //if it depend, this lead to :   
     //         every time i want to estimate my credit_price ,
     //        i need to get all other 's stocks ,so i need to calculate credit_price of other . 
 //             sell stocks effect the credit_price users .




 //return user's point after sell user's stocks.
 function points_after_sell (address _user_address,uint256 amount_of_INA_stocks) public view returns(uint256){
     // get stock aomount ;
    uint256 stock_amount = stock_owned_balance[_user_address][_user_address] ;
    require(stock_amount>=amount_of_INA_stocks,"try less stocks ");
    uint256 user_ID =get_userID(_user_address);
    uint256 _user_points = users[user_ID].user_point  ;

   return _user_points - (500*amount_of_INA_stocks) ;
 }
    
 ///other_address : it represent company_stock_address owned by caller ;
// other_address : it can be caller address itself ,which mean caller want to sell his stocks ;
function stock_to_sell(address other_address, uint256 _amount_to_sell) public payable  returns (bool){
        // here , if i sub it from owned_stocks may it effect to creited_price ??????.
        // so , i add stock_owned_balance_To_sell amount to prevent try sell more than what caller owned ;
    require(stock_owned_balance[msg.sender][other_address]>=_amount_to_sell+stock_owned_balance_To_sell[msg.sender][other_address],"you don't own enough stocks ");
    stock_owned_balance_To_sell[msg.sender][other_address] +=_amount_to_sell ;
    return  true ;
   }


//need for approve in INA_contact to spend token's users ;
//  calling by buyer ;
// it can be anther implement for this function  : based on how many INA sended by caller but i think it closer to invest method  ;
//front_end should @call get_user_stock_price before buy button to estimate number of INA_ have to approve then send 
   function buy(address owner_stock_address,address company_stock_address,uint256 _amount_stock_to_buy,uint256 _INA_sended) external  payable returns(bool){
                uint256 INA = _amount_stock_to_buy*get_user_stock_price(owner_stock_address);
                require(INA>=_INA_sended,"need more INA to be sended for buy");
    //later should resend to caller Remainder 
   require(stock_owned_balance_To_sell[owner_stock_address][company_stock_address]>=_amount_stock_to_buy,"this amount not able to buy");
   //@test require(INA_contact.transferFrom(msg.sender,owner_stock_address, INA),"faile ,can not transfer INA from buyer") ;

   stock_owned_balance_To_sell[owner_stock_address][company_stock_address] -= _amount_stock_to_buy ;
   stock_owned_balance[owner_stock_address][company_stock_address]  -= _amount_stock_to_buy ;
   stock_owned_balance[msg.sender][company_stock_address]          += _amount_stock_to_buy ;
   // I consider : only sell my stocks effect on my credit_price  ???
   if(owner_stock_address==company_stock_address){
       uint256 new_owner_stock_point = points_after_sell(owner_stock_address, _amount_stock_to_buy);
           uint256 user_ID =get_userID(owner_stock_address);
                   users[user_ID].user_point = new_owner_stock_point  ;
                   users[user_ID].user_stock_price = Credit_price(owner_stock_address);
                
   }
   return  true ;
   }

   //@ 
 function get_user_stock_price (address _user) public view returns(uint256){
  return users[get_userID(_user)].user_stock_price ;

 }

    }