//by jnbez 
//@ master need to find point calculate funtion ;
//why don't i use minting concept here (like erc20,...etc ?
 // if i use it ,  after some stocks exchange between users,  i can't determine who create this one,
 //the main idea of stock : 
 //is to  **still**  knowing  (after multi exhange of stock) who create this stock to determine exchangeable price  depend on creator (company) price .
 //if i use erc721 or erc721A i need mint new collection for every company to represent the stocks of it ,
 // // @ master should i ?
// this contract , i represent stocks as nested mapping ,parameter 1  is the currentowner ,parameter 2  is the creator(company) ;

//The points are increasing over time, so there is no danger that the user will try to sell (directly without our Dapp) Without updating his points. 
//He will earn more if he updates his points, which is done through our node.
// create and update points is called only by our node .to avoid calling from out our Dapp .
//our node will pay the fees cause it is the owner and the only owner can call updating or creating 
//@later should find Solution in backend to let user pay the cost fees of (updating or creating account ).
//matic/usdt chainlink : 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada 
//
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract Users   {
    AggregatorV3Interface internal priceFeed;
    //AggregatorV3Interface internal nftFloorPriceFeed;


   struct  user  {
        address user_address ;
       uint256  user_point ;}
       
       
 IERC20 public INA_contact;
 IERC721 public nfts_contract ;
 address INA_TOKEN ;
 address owner ;
//  uint256 contract_INA_balacne ;

mapping(address => mapping(address => uint256)) public stock_owned_balance;
mapping(address => mapping(address => uint256)) public stock_owned_balance_To_sell;
mapping(address => uint256) public  user_id;
mapping (address=>uint256) user_stock_price;
mapping (address=>uint256) user_last_point ;

// mapping to let other addresses to update , creating , to achive scalability by parallel programming in backend.

mapping (address=>uint8) our_node ;

 user [] public users ;

constructor(IERC20 _erc20_contract_address
//IERC721 _nfts,address _nfts_address
) {
        priceFeed = AggregatorV3Interface( 0xb4c4a493AB6356497713A78FFA6c60FB53517c63);
       // nftFloorPriceFeed = AggregatorV3Interface(_nfts_address);
        INA_contact = _erc20_contract_address;
       // nfts_contract = _nfts ;
        owner= msg.sender ;
    }

//modifier 


     // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(INA_contact.allowance(msg.sender, address(this)) >= amount, "Error");
        _;
    }


 modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }


// the call must be from our node addresses ,To ensure no call out of our Dapp
    modifier _our_node(){
        require(our_node[msg.sender]>=1,"not allow ,only our node ");
        _;
    }


// events :


   event log_create_user(address _user_address ,uint256 user_point,uint256 _user_stock_price) ;
   event log_collect_of_INA_stocks(address _user_address,uint256 _stock_owned_balance); 
   event log_update_point(address __owner_stock_address ,uint256 _points);
   event log_buy(address owner_stock_address,address indexed  company_stock_address,address indexed  _buyer,uint256 _amount_stock_to_buy,uint256 _INA_sended);
   event log_change_price(uint256 _new_price , uint256 _old_price,address indexed  _user);




//functions :




//only our node can update price and creating,Suppose there are 10000 users at the same time calling update method.
// They have to wait for the node to sign tx.
//Signing through multiple addresses is faster than through a single address.
//should use parallel programming in backend node  To reduce user waiting time by this addresses.

function add_our_node(address _new_address) public onlyOwner{
        our_node[_new_address]=1;
    }
function remove_our_node(address _old_address) public onlyOwner{
        our_node[_old_address] = 0;
    }

///

 function get_userID ( address _useraddress) public view returns (uint256){
        require(user_id[_useraddress]>=0,"Account did not Exist  ");

       return user_id[_useraddress] ;
   }
 
// function getSmartContractBalance() external view returns(uint) {
//     return INA_contact.balanceOf(address(this));
//      }




// after calling this ,have to call collect_number_of_INA_stocks to collect caller stocks based on point and live price.
function create_user(address _user_address ,uint256 _user_point,uint256 _user_stock_price  ) 
        public _our_node  {
            // only one account for one address
        require(user_id[_user_address]<=0,"address had account ");
        user memory _user = user({ 
            user_address :_user_address,
            user_point :_user_point});

        user_id[_user_address] =users.length;
        user_stock_price[_user_address]=_user_stock_price;
        user_last_point[_user_address] =0 ;
        emit log_create_user( _user_address, _user_point,_user_stock_price);
        users.push(_user); // push to the array
 }
 //call after create_user,or update point;
 // user who have  point should call it to get his stocks .
 //@later event-change price ;
function collect_of_INA_stocks() public  returns(uint256){
    require(user_id[msg.sender]>=0,"address had account ");

    uint256 _user_id = user_id[msg.sender];

    uint256 old_price = user_stock_price[msg.sender] ;
    require(users[_user_id].user_point>user_last_point[msg.sender],"no enough points to swap");
    stock_owned_balance[msg.sender][msg.sender] += number_of_INA_stocks(msg.sender);
    //to prevent attack :
    //without this equality  attacker try to call this function multi times to add more stocks ,
    user_last_point[msg.sender] =users[_user_id].user_point ;
    user_stock_price[msg.sender] = Credit_price(msg.sender);

    emit log_collect_of_INA_stocks(msg.sender,stock_owned_balance[msg.sender][msg.sender]);
    emit log_change_price(user_stock_price[msg.sender],old_price,msg.sender) ;
    return stock_owned_balance[msg.sender][msg.sender] ;
}



function number_of_INA_stocks  (address _user ) public view returns (uint256){
        require(user_id[_user]>=0,"Account did not Exist  ");
         uint256 user_ID =user_id[_user];
         uint256 _user_points = users[user_ID].user_point  ;
          uint256 a = _user_points - user_last_point[_user];

                 if(a > 0){
                     a=a/500;
                  }
                  else{
         a= 0 ;}
        return a ;
    }
    //0x7C97ba2C8a829b9B9506494379B160758924AFAB
function update_point(address _owner_stock_address ,uint256 points) public _our_node{
        uint256 user_ID =get_userID(_owner_stock_address);
        require(user_ID>=1,"Account did not Exist");
        uint256 _old_price =user_stock_price[_owner_stock_address];
        user_last_point[_owner_stock_address]=users[user_ID].user_point ;
         users[user_ID].user_point += points ;
         user_stock_price[_owner_stock_address] = Credit_price(_owner_stock_address);
        emit log_update_point(_owner_stock_address,points);
        emit log_change_price(user_stock_price[_owner_stock_address], _old_price, _owner_stock_address);
} 

   
  function INA_getLatestPrice() public view returns (uint256) {
        ( ,int price, , ,
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
 

    function Credit_price(address _user_address) public view returns (uint256){
        require(user_id[msg.sender]>=0,"Account did not Exist  ");
        uint256 user_ID =get_userID(_user_address);
        require(user_ID>=0,"user did not exist");

        uint256 a = users[user_ID].user_point ;
        uint256 b = INA_getLatestPrice() ;
//i suppose only  user's stocks effect on price ,so he should not sell his stocks.
//or should collect more point to get more stocks to get high price .
        uint256 c = stock_owned_balance[_user_address][_user_address];
        uint256 _Credit_price = a*b*c;
        return _Credit_price/1e18;
         //users[ _userID].score.mul(getLatestPrice());
    }


    

 ///other_address : it represent company_stock_address owned by caller ;
// other_address : it can be caller_address itself ,which mean caller want to sell his stocks,  ;
//other_address : if it was not caller_address ,mean caller want to sell his stocks in other_address company ;
function stock_to_sell(address other_address, uint256 _amount_to_sell) public payable  returns (bool){
        // here , if i sub amount from owned_stocks may it effect to creited_price ??????.
        // so , i add stock_owned_balance_To_sell amount to prevent try selling more than what caller owned ;
    require(stock_owned_balance[msg.sender][other_address]>=_amount_to_sell + stock_owned_balance_To_sell[msg.sender][other_address],"no enough stocks ");
    stock_owned_balance_To_sell[msg.sender][other_address] +=_amount_to_sell ;
    user_stock_price[msg.sender] = Credit_price(msg.sender);

    return  true ;
   }


//need for approve in INA_contact to spend token's users ;
//  calling by buyer ;
// there is  another implement for this function  : based on how many INA sended by caller but i think it closer to invest method  ;
//front_end should @call get_user_stock_price before buy button to estimate number of INA_ have to approve then send .
   function buy(address owner_stock_address,address company_stock_address,uint256 _amount_stock_to_buy,uint256 _INA_sended) external returns(bool){
                uint256 price =get_user_stock_price(owner_stock_address);
                uint256 INA = _amount_stock_to_buy*price;
                require(INA<=_INA_sended,"need more INA to be sended for buy");
    //later should resend to caller Remainder/ 
   require(stock_owned_balance_To_sell[owner_stock_address][company_stock_address]>=_amount_stock_to_buy,"this amount not able to buy");
    require(INA_contact.transferFrom(msg.sender,owner_stock_address, INA),"faile ,can not transfer INA from buyer") ;

   stock_owned_balance_To_sell[owner_stock_address][company_stock_address] -= _amount_stock_to_buy ;
   stock_owned_balance[owner_stock_address][company_stock_address]  -= _amount_stock_to_buy ;
   stock_owned_balance[msg.sender][company_stock_address]          += _amount_stock_to_buy ;
   user_stock_price[owner_stock_address] = Credit_price(owner_stock_address);
      // if he buy his own stocks , his price go higher than buying onther company's stock ;
   user_stock_price[msg.sender] = Credit_price(owner_stock_address);

   emit log_buy(owner_stock_address, company_stock_address, msg.sender, _amount_stock_to_buy, _INA_sended);
   emit log_change_price(user_stock_price[owner_stock_address], price, owner_stock_address);
//    }
   return  true ;
   }

   //@ 
 function get_user_stock_price (address _user) public view returns(uint256){
  return user_stock_price[_user] ;

 }

//for test buy function 
function getThisAddressINA_Balance(address b) public view returns (uint256) {
    return INA_contact.balanceOf(b);
}
// function get_user_nfts(address _user)   public view returns(uint256){
//  require(user_id[_user]>=0,"Account did not Exist  ");
//         return nfts_contract.balanceOf(_user) ;
// }
//  function NFT_getLatestPrice() public view returns (int) {
//         (  , int nftFloorPrice , ,,) = nftFloorPriceFeed.latestRoundData();

//         return nftFloorPrice; }

//     }
}
