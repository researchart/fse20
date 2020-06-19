# FairCon

**FairCon** checks fairness properties such as, the truthfulness, efficiency, optimality, and collusion-freeness, for
Ethereum smart contracts. It is based on the mechanism design theory and uses symbolic execution to automatically extract 
models from contract code and generate invariants for property verification. 

### Quick Start

#### 1. Pull from docker registry

```bash
docker pull liuyedocker/fse2020-faircon
```

#### 2. Run demo case (including all properties checking results)

```bash
docker run --name faircon_demo -it liuyedocker/fse2020-faircon
```

#### 3. Run experiments for checking fairness properties on auction cases (usually less than 1 hour)
(specs: Ubuntu 18.04.3 LTS desktop equipped with Intel Corei7 16-core and 32GB memory.)
```bash
docker run --name faircon_auction_check  -it liuyedocker/fse2020-faircon bash scripts/run_auction_check_experiment.sh
```

#### 4. Reproduce experiment results for all cases presented in the paper (about 3 days)
(specs: Ubuntu 18.04.3 LTS desktop equipped with Intel Corei7 16-core and 32GB memory.)
```bash
docker run --name faircon_all  -it liuyedocker/fse2020-faircon bash scripts/run_all_experiment.sh
```

#### 5. Bash into the Docker container
```bash
docker run -it  liuyedocker/fse2020-faircon bash
```
You will see:

```bash
/home/fairness> ls
scripts   contracts
```
The dataset is in `contracts` and you can customize the scripts to perform the experiments.
<!-- 
###  Customization

#### 1. Build Docker image

in the same directory, execute the following command.
```
    docker build  . -t  fse2020-faircon 
```

#### 2. Run the demo case

```bash
docker run --name faircon -it fse2020-faircon
```

#### 3. Run experiments for all cases

```bash
docker run --name faircon -it fse2020-faircon bash scripts/run_experiment.sh
``` -->

###  Verification and Validation Process

#### 1. Instrument harness contracts

Below is an example harness program generated for the contract `cryptoRomeAuction.sol`. 

* The function `_Main_` is the entry point where the symbolic execution starts. 
* There are three bidders specified with the format  `(msg_senderX, msg_valueX, pX)` using `declare_bidder`.  
* Assumptions about bidders are specified using `declare_assumption`. 
* After calling `bid()`, allocation and clear price are declared with `declare_allocation` and `declare_clearprice`, respectively.
* The bidders' utility functions are explicitly declared with `declare_utility`. 
* Finally, four fairness properties are supplied with `declare_check`.

__Original code__
```javascript
contract CryptoRomeAuction {
  // public address 
  uint256 public auctionStart;
  uint256 public auctionEnd;
  uint256 public extensionTime = 100000;
  uint256 public highestBid = 0;
  address payable public  highestBidder;
  mapping(address=>uint) refunds;
  function bid() public payable{
    if (now() < auctionStart)
      revert();
      if(now() >= auctionEnd)
        revert();
      uint duration = 1;
      if (msg.value < (highestBid + duration)){
        revert();
      }
      if (highestBid != 0) {
        refunds[highestBidder] += highestBid;
      }
      if (now() > auctionEnd - extensionTime) {
        auctionEnd = now() + extensionTime;
      }
      highestBidder = msg.sender;
      highestBid = msg.value;
   }
}
```
__Instrumented code__

```javascript
contract CryptoRomeAuction {
  // ...
  // Succinct rules
  function declare_bidder(address bidder, uint bid_price, uint valuation) public {}
  function declare_clearprice(uint price) public {}
  function declare_allocation(address winner) public {}
  function declare_utility(address bidder, uint utility) public {}
  function declare_assumption(bool assump) public {}
  // type 
  // - 0: truthful
  // - 1: collusion-free
  // - 2: efficient 
  // - 3: optimal
  function declare_check(uint check_type) public {}
  // type
  //  - 0 : auction
  //  - 1 : voting
  function declare_type(uint check_type) public {}
  // type
  // - 0: Allocation -> Top bidder
  // - 1: Transfer -> 1st-Price
  // - 2: Transfer -> 2nd-Price
  function declare_invariant(uint check_type) public{}
  function declare_variable_addr(address addr) public{}
  function declare_variable_uint(uint n) public{}
  function declare_smt_uint(uint n) public{}
 
  function _Main_(address payable msg_sender1, uint p1, uint msg_value1, uint msg_gas1, 
                  uint block_timestamp1, 
                  address payable msg_sender2, uint p2, uint msg_value2, uint msg_gas2, 
                  uint block_timestamp2, 
                  address payable msg_sender3, uint p3, uint msg_value3, uint msg_gas3, 
                  uint block_timestamp3) public {
    require(!(msg_sender1 == highestBidder || msg_sender2 == highestBidder || msg_sender3 == highestBidder));
    require(!(msg_sender1 == msg_sender2 || msg_sender1 == msg_sender3 || msg_sender2 == msg_sender3));
    declare_assumption(extensionTime > 0);
    declare_assumption(highestBid == 0);

    declare_assumption(p1 > 100000000000 && p1 < 200000000000);
    declare_assumption(p2 > 100000000000 && p2 < 200000000000);
    declare_assumption(p3 > 100000000000 && p3 < 200000000000);
    declare_assumption(msg_value1 > 100000000000 && msg_value1 < 200000000000);
    declare_assumption(msg_value2 > 100000000000 && msg_value2 < 200000000000);
    declare_assumption(msg_value3 > 100000000000 && msg_value3 < 200000000000);

    declare_assumption(utilities[msg_sender1] == 0);
    declare_assumption(utilities[msg_sender2] == 0);
    declare_assumption(utilities[msg_sender3] == 0);

    declare_assumption(benefits[msg_sender1] == 0);
    declare_assumption(benefits[msg_sender2] == 0);
    declare_assumption(benefits[msg_sender3] == 0);

    declare_assumption(payments[msg_sender1] == 0);
    declare_assumption(payments[msg_sender2] == 0);
    declare_assumption(payments[msg_sender3] == 0);

    declare_type(0);
    declare_bidder(msg_sender1, msg_value1, p1);
    declare_bidder(msg_sender2, msg_value2, p2);
    declare_bidder(msg_sender3, msg_value3, p3);

    // Each player performs the 'bid' action
    bid(msg_sender1,msg_value1,msg_gas1,block_timestamp1);
    bid(msg_sender2,msg_value2,msg_gas2,block_timestamp2);
    bid(msg_sender3,msg_value3,msg_gas3,block_timestamp3);

    declare_allocation(highestBidder);
    declare_clearprice(highestBid);

    declare_utility(msg_sender1, p1-highestBid); 
    declare_utility(msg_sender2, p2-highestBid); 
    declare_utility(msg_sender3, p3-highestBid); 

    declare_check(0);
    declare_check(1);
    declare_check(2);
    declare_check(3);
  }
}
```

#### 2. Run the demo case with Docker

```bash
docker run --name faircon -it liuyedocker/fse2020-faircon
```

The console log should look like the following:

<pre>%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
symbolically execute function [_Main_]
Mechanism model check
0
bidder|truthful bid|truthful utility|untruthful bid|untruthful utility
&quot;\x01&quot; 100000000001 0 100000000000 1
untruthful
▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
▌ bidder ┃     bid      ┃ valuation    ┃ utility ┃ price        ┃ allocation ▐
▌━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━▐
▌ &quot;\x01&quot; ┃ 100000000001 ┃ 100000000001 ┃ 0       ┃ 100000000001 ┃ true       ▐
▌ &quot;\x04&quot; ┃ 109999999999 ┃ 109999999999 ┃ 0       ┃ 100000000001 ┃ false      ▐
▌ &quot;\x80&quot; ┃ 109999999999 ┃ 109999999999 ┃ 0       ┃ 100000000001 ┃ false      ▐
▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟

variables
1
comparison|p1|bid1|p2|b2|allocation|group utility
truthful:&quot;\x01&quot;:100000000001  &quot;\x10&quot;:109999999999 &quot;&quot; |30613
collusion:&quot;\x01&quot;:100000030614  &quot;\x10&quot;:110000030614 &quot;\x10&quot; 30614
collusion
▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
▌ bidder ┃     bid      ┃ valuation    ┃ utility ┃ price        ┃ allocation ▐
▌━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━▐
▌ &quot;\x01&quot; ┃ 100000000001 ┃ 100000030614 ┃ 30613   ┃ 100000000001 ┃ true       ▐
▌ &quot;\x10&quot; ┃ 109999999999 ┃ 110000061228 ┃ 0       ┃ 100000000001 ┃ false      ▐
▌ &quot;\x00&quot; ┃ 109999999999 ┃ 109999999999 ┃ 0       ┃ 100000000001 ┃ false      ▐
▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟

variables
2
Highest Valuation Bidder:&quot;\x11&quot; is not the winner
not efficient
▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
▌ bidder ┃     bid      ┃ valuation    ┃ utility ┃ price        ┃ allocation ▐
▌━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━▐
▌ &quot;\x01&quot; ┃ 100000000001 ┃ 100000030614 ┃ 30613   ┃ 100000000001 ┃ true       ▐
▌ &quot;\x11&quot; ┃ 109999999999 ┃ 110000061228 ┃ 0       ┃ 100000000001 ┃ false      ▐
▌ &quot;\x10&quot; ┃ 109999999999 ┃ 109999999999 ┃ 0       ┃ 100000000001 ┃ false      ▐
▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟

variables
3
Highest Price Bidder:110000000002 is not the clear price
not optimal
▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜
▌ bidder ┃     bid      ┃ valuation    ┃ utility ┃ price        ┃ allocation ▐
▌━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━╋━━━━━━━━━━━━━━╋━━━━━━━━━━━━▐
▌ &quot;\x10&quot; ┃ 100000000001 ┃ 110000000001 ┃ 0       ┃ 110000000001 ┃ false      ▐
▌ &quot;\x00&quot; ┃ 110000000001 ┃ 110000061230 ┃ 61229   ┃ 110000000001 ┃ true       ▐
▌ &quot;\x01&quot; ┃ 110000000002 ┃ 110000000002 ┃ 0       ┃ 110000000001 ┃ false      ▐
▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟

variables
*************************************
*         report                    *
*************************************
* model construction time: 3.826s
* property/invariant checking time: 0.114s
*              total time: 3.94s
*************************************
</pre>

* Aboved shows the sample output: 
    - Four counterexamples are found against the Truthfulness, Collusion-freeness, Optimality, and Efficiency properties.  
    - The time spent on model extraction and property checking are also included in the report.

#### 3. What the log really says

* *Is the contract truthful?* **NO**
    * Reason: *bidder "\x01" can get more utility by not acting truthfully in the auction.*

|Bidder |Truthful bid  |Truthful utility |Untruthful bid |Untruthful utility |
|-------|--------------|-----------------|---------------|-------------------|
|"\x01" | 100000000001 |               0 | 100000000000  |                 1 |

* In contrast, a truthful bid look like this:

| Bidder   |    Bid        | Valuation    | Utility | Price        | Allocation |
|----------|---------------|--------------|---------|--------------|------------|
| "\x01"   | 100000000001  | 100000000001 | 0       | 100000000001 | true       |
| "\x10"   | 109999999999  | 109999999999 | 0       | 100000000001 | false      |
| "\x00"   | 109999999999  | 109999999999 | 0       | 100000000001 | false      |
