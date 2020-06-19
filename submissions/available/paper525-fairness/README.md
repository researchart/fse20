This artifact contains the dataset of Ethereum smart contracts (original code and instrumented harness
code), raw results of our tool FairCon running on the dataset, and result summaries.
The artifact is freely available at a permanent link: <https://doi.org/10.21979/N9/0BEVRT>

To reproduce the results, one can run FairCon on the dataset with the provided Docker image:

```bash
docker pull liuyedocker/fse2020-faircon
docker run --name faircon -it liuyedocker/fse2020-faircon bash scripts/run_all_experiment.sh
```
Instructions for running FairCon is also available at: <https://github.com/ntu-SRSLab/FairCon> 

The detailed descriptions about the dataset are given below.

#### 1. Directory Structures
```
📦 dataset-fse2020-log
 ┣ 📂 auction
 ┃ ┣ 📂 collusion
 ┃ ┃ ┣ 📂 log
 ┃ ┃ ┃ ┣ 📜 ....log
 ┃ ┃ ┣ 📜 Auction-0x3280660b3bafdad41a774938ab5a34ae463edbfe.sol
 ┃ ┃ ┣ 📜 Auction-0x5b566b473bb0ea8dc0fc6047dd623e5fa3b42307.sol
 ┃ ┃ ┣ 📜 Auction-0x64cc1a7dfe15f69b2b5dbe80b4e40a51aaa7917c.sol
 ┃ ┃ ┣ 📜 AuctionItem-0x91d0013742c6a6a033d46ac9da7b5e0416c35e24.sol
 ┃ ┃ ┣ 📜 AuctionManager-0x37512eec5e3ee7843a1ab59ef99fb52589037774.sol
 ┃ ┃ ┣ 📜 AuctionMultipleGuaranteed-0x6c1c2fd38fccc0b010f75b2ece535cf57543ddcd.sol
 ┃ ┃ ┣ 📜 AuctionPotato-0x433b189d5fbdfee89e3a9f4c6b9469495fcb00f1.sol
 ┃ ┃ ┣ 📜 BetterAuction-0x215a427c5f35c375525ecafa37c05d4b3ec9b573.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction.sol
 ┃ ┃ ┣ 📜 Deed-0xed139a28ec75a336bb1dcd6e3a0aba96c8217774.sol
 ┃ ┃ ┣ 📜 EtherAuction-0x2e63cceffa42b095f0bd6d0fcadb521200b8fef5.sol
 ┃ ┃ ┗ 📜 hotPotatoAuction-0x34eee0379a71e445b0dc52bda1d733c449ef1246.sol
 ┃ ┣ 📂 efficient
 ┃ ┣ 📂 optimal
 ┃ ┗ 📂 truthful
 ┣ 📂 invariant_auctions
 ┃ ┣ 📂 collusion
 ┃ ┃ ┣ 📜 Deed-0xed139a28ec75a336bb1dcd6e3a0aba96c8217774.sol
 ┃ ┃ ┗ 📜 EtherAuction-0x2e63cceffa42b095f0bd6d0fcadb521200b8fef5.sol
 ┃ ┣ 📂 efficient
 ┃ ┃ ┗ 📜 Deed-0xed139a28ec75a336bb1dcd6e3a0aba96c8217774.sol
 ┃ ┣ 📂 optimal
 ┃ ┃ ┣ 📜 4-AuctionItem-0x91d0013742c6a6a033d46ac9da7b5e0416c35e24.sol
 ┃ ┃ ┗ 📜 ....sol
 ┃ ┗ 📂 truthful
 ┃ ┃ ┣ 📜 4-Deed-0xed139a28ec75a336bb1dcd6e3a0aba96c8217774.sol
 ┃ ┃ ┗ 📜 ...sol
 ┣ 📂 performance_auction
 ┃ ┣ 📂 collusion
 ┃ ┃ ┣ 📂 log
 ┃ ┃ ┃ ┣ ....log
 ┃ ┃ ┣ 📜 CryptoRomeAuction3.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction4.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction5.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction6.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction7.sol
 ┃ ┃ ┣ 📜 CryptoRomeAuction8.sol
 ┃ ┃ ┗ 📜 CryptoRomeAuction9.sol
 ┃ ┣ 📂 efficient
 ┃ ┣ 📂 optimal
 ┃ ┗ 📂 truthful
 ┣ 📂 result
 ┃ ┣ 📂 raw
 ┃ ┃ ┗ ....csv
 ┃ ┣ 📜 summary_auction.csv
 ┃ ┣ 📜 summary_performanc.csv
 ┃ ┣ 📜 summary_voting-0-1.csv
 ┃ ┗ 📜 summary_voting.csv
 ┣ 📂 voting-0-1
 ┃ ┣ 📂 collusion
 ┃ ┃ ┣ 📂 log
 ┃ ┃ ┃ ┣ 📜 ....log
 ┃ ┃ ┣ 📜 Association-0xd20a1225cf7410616a5a826bffbef4cd22019030.sol
 ┃ ┃ ┣ 📜 Ballot-0xfce2e88f90927d5e5a539f1c223a6c6eeadb6cff.sol
 ┃ ┃ ┣ 📜 Ballot.sol
 ┃ ┃ ┣ 📜 HIDERA-0x96906c50c41b3252279c3e2cddc4a59493aadace.sol
 ┃ ┃ ┗ 📜 SBIBank-0x28aC77611bf3ae7B776AC7ecd79119D3C161574D.sol
 ┃ ┣ 📂 efficient
 ┃ ┗ 📂 truthful
 ┣ 📂 voting-R
 ┃ ┣ 📂 collusion
 ┃ ┣ 📂 efficient
 ┃ ┗ 📂 truthful
 ┃ ┃ ┣ 📂 log
 ┃ ┃ ┃ ┣ 📜 ....log
 ┃ ┃ ┣ 📜 Association-0xd20a1225cf7410616a5a826bffbef4cd22019030.sol
 ┃ ┃ ┗ 📜 ....sol
 ┗ 📜 README.md
 ```

| Directories         | Purposes                                                        | Descriptions                     |
|---------------------|-----------------------------------------------------------------|----------------------------------|
| auction             | Evaluate __property checking__ on auctions                      | Including cases and results      |
| invariant_auction   | Evaluate __invariant testing__ on auctions                      | Including cases                  |
| performance_auction | __Performance evaluation__ on auction                           | Including cases and results      |
| voting-R            | Evaluate __property checking__ on voting with __R__ valuation   | Including cases and results      |
| voting-0-1          | Evaluate __property checking__ on voting with __0-1__ valuation | Including cases and results      |
| result              | __Experiment results__                                          | Including raw result and summary |

#### 2. Smart contracts used in the experiment 


| Type                      | Contract names            | Retrived from                                                                                                              |
|---------------------------|---------------------------|--------------------------------------------------------------------------------------------------------------------------- |
| Auction                   | Auction1                  | [0x5b566b473bb0ea8dc0fc6047dd623e5fa3b42307](https://etherscan.io/address/0x5b566b473bb0ea8dc0fc6047dd623e5fa3b42307#code) |
|                           | Auction2                  | [0x64cc1a7dfe15f69b2b5dbe80b4e40a51aaa7917c](https://etherscan.io/address/0x64cc1a7dfe15f69b2b5dbe80b4e40a51aaa7917c#code) |
|                           | Auction3                  | [0x3280660b3bafdad41a774938ab5a34ae463edbfe](https://etherscan.io/address/0x3280660b3bafdad41a774938ab5a34ae463edbfe#code) |
|                           | AuctionItem               | [0x91d0013742c6a6a033d46ac9da7b5e0416c35e24](https://etherscan.io/address/0x91d0013742c6a6a033d46ac9da7b5e0416c35e24#code) |
|                           | AuctionManager            | [0x37512eec5e3ee7843a1ab59ef99fb52589037774](https://etherscan.io/address/0x37512eec5e3ee7843a1ab59ef99fb52589037774#code) |
|                           | AuctionMultipleGuaranteed | [0x6c1c2fd38fccc0b010f75b2ece535cf57543ddcd](https://etherscan.io/address/0x6c1c2fd38fccc0b010f75b2ece535cf57543ddcd#code) |
|                           | AuctionPotato             | [0x433b189d5fbdfee89e3a9f4c6b9469495fcb00f1](https://etherscan.io/address/0x433b189d5fbdfee89e3a9f4c6b9469495fcb00f1#code) |
|                           | BetterAuction             | [0x215a427c5f35c375525ecafa37c05d4b3ec9b573]
(https://etherscan.io/address/0x215a427c5f35c375525ecafa37c05d4b3ec9b573#code) |
|                           | CryptoRomeAuction         | [0x760898e1e75dd7752db30bafa92d5f7d9e329a81](https://etherscan.io/address/0x760898e1e75dd7752db30bafa92d5f7d9e329a81#code) |
|                           | Deed                      | [0xed139a28ec75a336bb1dcd6e3a0aba96c8217774](https://etherscan.io/address/0xed139a28ec75a336bb1dcd6e3a0aba96c8217774#code) |
|                           | EtherAuction              | [0x2e63cceffa42b095f0bd6d0fcadb521200b8fef5](https://etherscan.io/address/0x2e63cceffa42b095f0bd6d0fcadb521200b8fef5#code) |
|                           | hotPotatoAuction          | [0x34eee0379a71e445b0dc52bda1d733c449ef1246](https://etherscan.io/address/0x34eee0379a71e445b0dc52bda1d733c449ef1246#code) |
| Voting                    | HIDERA                    | [0x96906c50c41b3252279c3e2cddc4a59493aadace](https://etherscan.io/address/0x96906c50c41b3252279c3e2cddc4a59493aadace#code) |
|                           | Association               | [0xd20a1225cf7410616a5a826bffbef4cd22019030](https://etherscan.io/address/0xd20a1225cf7410616a5a826bffbef4cd22019030#code) |
|                           | Ballot                    | [0xfce2e88f90927d5e5a539f1c223a6c6eeadb6cff](https://etherscan.io/address/0xfce2e88f90927d5e5a539f1c223a6c6eeadb6cff#code) |
|                           | SBIBank                   | [0x28aC77611bf3ae7B776AC7ecd79119D3C161574D](https://etherscan.io/address/0x28aC77611bf3ae7B776AC7ecd79119D3C161574D#code) |
|                           | Ballot-doc                | [Solidity Official Documentation](https://solidity.readthedocs.io/en/v0.6.3/solidity-by-example.html#voting)     others    |


#### 3. Result Summaries

For example, the result of __performance testing__ on CryptoRomeAuction shows:

| Contract Names         | Construction time | Checking time | Total time | Total | T | C | O | E |
|------------------------|-------------------|---------------|------------|-------|---|---|---|---|
| CryptoRomeAuction3.sol | 8.10              | 0.08          | 8.18       | 18    | 1 | 1 | 1 | 1 |
| CryptoRomeAuction4.sol | 29.59             | 0.10          | 29.69      | 54    | 1 | 1 | 1 | 1 |
| CryptoRomeAuction5.sol | 106.34            | 0.12          | 106.46     | 162   | 1 | 1 | 1 | 1 |
| CryptoRomeAuction6.sol | 378.10            | 0.17          | 378.27     | 486   | 1 | 1 | 1 | 1 |
| CryptoRomeAuction7.sol | 1262.29           | 0.32          | 1262.61    | 1458  | 1 | 1 | 1 | 1 |
| CryptoRomeAuction8.sol | 4301.52           | 0.92          | 4302.44    | 4374  | 1 | 1 | 1 | 1 |
| CryptoRomeAuction9.sol | 14708.33          | 4.42          | 14712.72   | 13122 | 1 | 1 | 1 | 1 |
