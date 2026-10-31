# Block Zero group governance: test matrix (wBLOZ-only payouts)

Generated 2026-10-31 20:45 UTC from the result files of `tests/test_bloz_gov_matrix.py` (real contracts, real community server, counting modes person / linear / logarithmic / both, quorum, deadline, double vote, non-member, cancel, veto, expiry, wBLOZ-only negative tests, server checks, Verified requirement).

## Block Zero test chain (97097, real time)

Deploy: Governor `0x0aF45fe48957f55c48847F9811932ca73053aBE4` (Test wBLOZ `0x8DD757e108D7d868Ed81D81F01A0F660BC5A64CB`), tx `0x6611b54d961e…` · Run 676754 · Finished 2026-10-31T20:36Z

| Case | Count | Votes | People (yes/no/abstain) | Weight | Result | Payout | Tx (proposal / votes / payout) |
|---|---|---|---|---|---|---|---|
| P1 person pass 2:1 | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0x3f77db4eb8…` / `0x499e580b…`, `0x9af155a7…`, `0x2ba627d8…` / `0xa67732b671…` |
| P2 person reject 1:2 | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x6b1d1aa606…` / `0x4489f6a2…`, `0xe0330d65…`, `0xd9646854…` / - |
| P3 person quorum missed (1 voter, quorum 2) | person | alice:Y | [1, 0, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xc0e91f6e00…` / `0x400e150b…` / - |
| P4 person tie 1:1 | person | alice:Y, bob:N | [1, 1, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x669eb73b45…` / `0x7bc55376…`, `0xe6eed876…` / - |
| P5 person abstentions count for quorum | person | alice:Y, bob:A, carol:A | [1, 0, 2] | [0.0, 0.0, 0.0] | executed | yes | `0xbd9c10b41d…` / `0x6c10348d…`, `0xa083136b…`, `0x1fb43d22…` / `0xebac824f77…` |
| P6 person: alice 1000 BLOZ does not outweigh | person | alice:Y, bob:N, carol:N | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x0e2db070cc…` / `0x00b780d5…`, `0x516e64d9…`, `0x201ea8a5…` / - |
| L1 linear pass (alice 1000 beats 2 persons) | linear | alice:Y, bob:N, carol:N | [1, 2, 0] | [1000.0, 110.0, 0.0] | executed | yes | `0xf64dda3324…` / `0xdcf0424f…`, `0x46856a66…`, `0x15a6dc31…` / `0x80219e0246…` |
| L2 linear reject | linear | alice:N, bob:Y, carol:Y | [2, 1, 0] | [110.0, 1000.0, 0.0] | defeated | no | `0x69908dece9…` / `0x73ee5848…`, `0x986cace6…`, `0x4287b63b…` / - |
| L3 linear: dave without voter ID counts | linear | dave:Y, bob:N | [1, 1, 0] | [500.0, 100.0, 0.0] | executed | yes | `0xc38e343429…` / `0x700e047b…`, `0x45a301ce…` / `0xb4bfe0c6e5…` |
| G1 log pass (small holders outweigh the whale) | log | alice:N, bob:Y, carol:Y, dave:Y | [3, 1, 0] | [10.13, 6.66, 0.0] | executed | yes | `0x212f01680a…` / `0x3f629774…`, `0x65afb2c5…`, `0x3e9b3a26…`, `0x0eb89635…` / `0x7c654dfa06…` |
| G2 same votes linear: rejected (whale wins) | linear | alice:N, bob:Y, carol:Y, dave:Y | [3, 1, 0] | [610.0, 1000.0, 0.0] | defeated | no | `0xdc7c00d779…` / `0x1ecccb0a…`, `0x89150940…`, `0x43f091fb…`, `0x1905595e…` / - |
| G3 log reject | log | alice:Y, bob:N, carol:N | [1, 2, 0] | [6.66, 4.46, 0.0] | defeated | no | `0x3cb8d2b6ab…` / `0x0bf22cbc…`, `0xf9f9c6ca…`, `0x5d38f8f2…` / - |
| B1 linear+person both yes | linear+person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [1100.0, 10.0, 0.0] | executed | yes | `0x386998f538…` / `0xe5f48442…`, `0x8a17c27c…`, `0x25cd5996…` / `0xa39ed92a23…` |
| B2 linear+person: tokens yes, people no | linear+person | alice:Y, bob:N, carol:N | [1, 2, 0] | [1000.0, 110.0, 0.0] | defeated | no | `0x58c8561902…` / `0x5c0c3501…`, `0x95f22b84…`, `0x4e5a6b4f…` / - |
| B3 linear+person: people yes, tokens no | linear+person | alice:N, bob:Y, carol:Y | [2, 1, 0] | [110.0, 1000.0, 0.0] | defeated | no | `0xbeb8858ad7…` / `0xbfd35d50…`, `0x0aecbee3…`, `0xe912347d…` / - |
| B4 log+person both yes (dave tokens only) | log+person | alice:N, bob:Y, carol:Y, dave:Y | [2, 1, 0] | [10.13, 6.66, 0.0] | executed | yes | `0x59e088d106…` / `0xa00991c0…`, `0xea7cd587…`, `0x431712f2…`, `0x1a8548c3…` / `0xe64389c0a1…` |
| B5 log+person: people no | log+person | alice:Y, bob:N, carol:N, dave:Y | [1, 2, 0] | [12.33, 4.46, 0.0] | defeated | no | `0x8b71044805…` / `0xc58ccafe…`, `0x7ee078c3…`, `0xb3a5d1d7…`, `0x2f25f0a4…` / - |
| T1 wBLOZ payout 100 after yes | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0x82c1ec98a3…` / `0xf5c20e7d…`, `0xf1644dc0…`, `0x7d3651b8…` / `0x683d8873bc…` |
| T2 wBLOZ payout rejected: nothing moves | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xc8d46fcaff…` / `0x4fb6c2d9…`, `0x003efaff…`, `0x64603fa5…` / - |
| X1 non-member calls execute() | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0xb64760af0a…` / `0x179ce018…`, `0x8b33d273…`, `0x10fdefb1…` / `0x1f3883bd4d…` |
| X2 live results hidden, payout still runs | linear+person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [1100.0, 10.0, 0.0] | executed | yes | `0xa81a05d16f…` / `0x13f908b0…`, `0x659d1c3b…`, `0xfe1607b3…` / `0x6f11adbeee…` |
| Q1 plain question without payment passes | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | succeeded | - | `0xa87bc0d252…` / `0x5fc59e95…`, `0x0db57edf…`, `0xdeddf4fd…` / - |
| Q2 plain question without payment rejected | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xd9168cb836…` / `0xc0da36fa…`, `0x559501b6…`, `0x00d311b2…` / - |

### Rule, negative and server-side cases

**R rules (one payment vote)**
- propose_tx: `0xf3a1a3314e57fe0f8b683279d992dd3842003d556c86cbc4ed2b39724d2e29c0`
- votes: `0x700772e5f6220a593bb16e4785781dc83034081c2695810e02dcc3520bca36f7`, `0x3492db37ea9806f8a004d758a84a1493ec3868ac03c78bd445f7f4eff277fdb7`
- treasury: `0x723F37DE81a44d62b1e4D2319CB429FA0F2C2b07`
- Stimme vor Beginn (Vertrag): WrongState
- Nicht-Mitglied (Server): Only members who joined before this vote started can vote.
- Nicht-Mitglied (Vertrag): NotMember
- Empfängerin stimmt (Vertrag): RecipientCantVote
- Ohne Voter-ID, nur Person (Server): You need a Block Zero voter ID to vote on chain. Get it on your account page (free).
- Ohne Voter-ID, nur Person (Vertrag): NoVoterId
- Doppelstimme (Vertrag): AlreadyVoted; Server-Antwort: The network refused the transaction: VM Exception while processing transaction: revert
- execute vor Fristende: WrongState
- execute im Timelock: WrongState
- Stimme nach Fristende (Server): The network refused the transaction: VM Exception while processing transaction: revert; (Vertrag): WrongState
- Verfall nach Gnadenfrist (14 Tage): nur lokal geprüft
- Final state: succeeded

**C cancel by creator after 2 yes votes**
- propose_tx: `0x2ad39a5bfb8ffdd42a84250fa68533c1f459fe0968a0201798c7de51fdb54525`
- cancel_tx: `0x2267f1ec871d5f5525c485e2717fdcfff0e02627d324b6ee58e150d6bfb7cabc`
- Final state: cancelled

**V guardian veto after 2 yes votes**
- propose_tx: `0xf3cefd43f16a2a0825ad5d4f8f9838b9805e2ee9463b350ab92f9dc944fb4e5a`
- veto_tx: `0x65c8ccc00eeea369e1c9f9aaed1b38323d465cce2398622ba4a15a280d5458df`
- Final state: vetoed

**H show_live off**
- propose_tx: `0x8a93c2c875bbd2e2fa7745af0267dc59f229c9f0ac35a89466431e4de7f3c51d`
- Final state: Yes

**N wBLOZ only (negative tests)**
- treasury: `0xdd46bA18745bB5b42FEA5f207b1Cb98Bb941a880`
- BNB an Kasse: abgelehnt (0x1102c2248427070533debcf8dc40768df387035155ea53f9a11a5006a7e15a1e), Kasse 0 BNB
- Kasse pay(address,address,uint256,uint256) (frank): revert:{'message': 'VM Exception while processing transaction: revert', 'stack': 'CallE
- Kasse execute(address,uint256,bytes) (frank): revert:{'message': 'VM Exception while processing transaction: revert', 'stack': 'CallE
- Kasse rescue(address,address,uint256) (founder): revert:{'message': 'VM Exception while processing transaction: revert', 'stack': 'CallE
- Kasse pay(address,uint256,uint256) (frank): NotGovernor
- Kasse pay(address,uint256,uint256) (founder): NotGovernor
- pay() als Transaktion durch Fremde: abgelehnt, Kasse 1000 tWBLOZ
- Antrag BNB (Vertrag): TokenNotAllowed
- Antrag Fremdtoken (Vertrag): TokenNotAllowed
- Antrag über Deckel (Vertrag): AmountTooHigh
- maxAmount(BNB)=0, WBLOZ()=0x8dd757e108d7d868ed81d81f01a0f660bc5a64cb
- Server BNB: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Server DOGE: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Server über Deckel: The maximum per vote is 5000 tWBLOZ.
- Anzeige: Salden {'tWBLOZ': '0'}, Deckel {'tWBLOZ': '5000'}

**S server-side creation checks**
- keine Zählart: Please choose how votes are counted (one BLOZ one vote, one person one vote, or both).
- linear UND log zugleich: Choose linear OR logarithmic balance counting, not both (you can add one person, one vote).
- Betrag über Deckel (5000 tWBLOZ): The maximum per vote is 5000 tWBLOZ.
- Empfänger = Gruppen-Kasse: Please give a valid recipient wallet address (not the group wallet).
- unbekannter Token: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Mitglied ohne Verwaltungsrecht erstellt Abstimmung: Only the founder or an admin can create votes.
- Nicht-Mitglied erstellt Abstimmung: Only the founder or an admin can create votes.
- Gruppe ohne Wallet: Web-Abstimmung ohne Kette, keine Auszahlung möglich (so gewollt)
- Sichtbarkeit: Standard nur Mitglieder; Gründer-Schalter wallet_public zeigt Adresse, Saldo, Kassenbuch öffentlich; Einzelstimmen nie

**VF verified requirement**
- strikt, nur Wallet: Not all checks pass yet: discord, discord_age, bloz_addr.
- strikt, voll verifiziert: Voter-ID erteilt, tx 0xb822eda4c1192ef3669aa212f2aa96688a11f4b14f6f17a73815ce2a4d234179
- Verified-only-Gruppe, frank (nur Wallet): Link Discord and your BLOZ address to join this Verified-only group (1 of 3).
- Verified-only-Gruppe, dave (voll verifiziert): beigetreten
- Verified-only-Gruppe, alice (Voter-ID, aber ohne Discord/BLOZ-Adresse): Link Discord and your BLOZ address to join this Verified-only group (1 of 3).

**Failed checks:** All checks passed.

## Local Hardhat chain (31337, time warped)

Deploy: Governor `0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9` (Test wBLOZ `0x5FbDB2315678afecb367f032d93F642f64180aa3`), tx `0x840ed3d7ba4e…` · Run 1 · Finished 2026-10-31T19:58Z

| Case | Count | Votes | People (yes/no/abstain) | Weight | Result | Payout | Tx (proposal / votes / payout) |
|---|---|---|---|---|---|---|---|
| P1 person pass 2:1 | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0xb765de5620…` / `0x5e06032c…`, `0x486bae5c…`, `0x8962a569…` / `0xce32c4f0b3…` |
| P2 person reject 1:2 | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x8fcc38f5d5…` / `0x192b708e…`, `0x87c4c638…`, `0x003fb67f…` / - |
| P3 person quorum missed (1 voter, quorum 2) | person | alice:Y | [1, 0, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xb13f4ba8a1…` / `0x87debb2f…` / - |
| P4 person tie 1:1 | person | alice:Y, bob:N | [1, 1, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x80ac6a2347…` / `0xeb5f2399…`, `0x402ad142…` / - |
| P5 person abstentions count for quorum | person | alice:Y, bob:A, carol:A | [1, 0, 2] | [0.0, 0.0, 0.0] | executed | yes | `0x6b310223f2…` / `0x7e1b9249…`, `0x68f2259e…`, `0xe6d81bab…` / `0x7f5be38646…` |
| P6 person: alice 1000 BLOZ does not outweigh | person | alice:Y, bob:N, carol:N | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xac26108341…` / `0x005f0b30…`, `0xb290fea8…`, `0x5fd77f96…` / - |
| L1 linear pass (alice 1000 beats 2 persons) | linear | alice:Y, bob:N, carol:N | [1, 2, 0] | [1000.0, 110.0, 0.0] | executed | yes | `0x0b5c7c2e8f…` / `0xc20eeb4c…`, `0x9532f997…`, `0x7d7e1617…` / `0xcd6f2d8238…` |
| L2 linear reject | linear | alice:N, bob:Y, carol:Y | [2, 1, 0] | [110.0, 1000.0, 0.0] | defeated | no | `0xea9804f387…` / `0x11b5be08…`, `0x43801035…`, `0x97e5c140…` / - |
| L3 linear: dave without voter ID counts | linear | dave:Y, bob:N | [1, 1, 0] | [500.0, 100.0, 0.0] | executed | yes | `0xca11e76be0…` / `0x7c696ab2…`, `0xe287755b…` / `0x6fa9f8655a…` |
| G1 log pass (small holders outweigh the whale) | log | alice:N, bob:Y, carol:Y, dave:Y | [3, 1, 0] | [10.13, 6.66, 0.0] | executed | yes | `0x41797e1169…` / `0x1722ef55…`, `0x7eba081f…`, `0xc4759b75…`, `0x44bccfe6…` / `0xcedd0d518a…` |
| G2 same votes linear: rejected (whale wins) | linear | alice:N, bob:Y, carol:Y, dave:Y | [3, 1, 0] | [610.0, 1000.0, 0.0] | defeated | no | `0xe650f5c5d7…` / `0xc49cb06c…`, `0x0c414ac2…`, `0xd72fc919…`, `0xe3704438…` / - |
| G3 log reject | log | alice:Y, bob:N, carol:N | [1, 2, 0] | [6.66, 4.46, 0.0] | defeated | no | `0xa817afeabe…` / `0x9d4e86a5…`, `0xd209d417…`, `0x3902d9e3…` / - |
| B1 linear+person both yes | linear+person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [1100.0, 10.0, 0.0] | executed | yes | `0x27aab9259e…` / `0x2f2f41e4…`, `0xc0e7500c…`, `0x62252316…` / `0x44762efc60…` |
| B2 linear+person: tokens yes, people no | linear+person | alice:Y, bob:N, carol:N | [1, 2, 0] | [1000.0, 110.0, 0.0] | defeated | no | `0x0d96194c84…` / `0x12d9311d…`, `0xda2ca3ce…`, `0x9eb7c806…` / - |
| B3 linear+person: people yes, tokens no | linear+person | alice:N, bob:Y, carol:Y | [2, 1, 0] | [110.0, 1000.0, 0.0] | defeated | no | `0x2b3664cff9…` / `0xa5518986…`, `0x343d1823…`, `0x4f85cdcf…` / - |
| B4 log+person both yes (dave tokens only) | log+person | alice:N, bob:Y, carol:Y, dave:Y | [2, 1, 0] | [10.13, 6.66, 0.0] | executed | yes | `0x2f0f8b393b…` / `0x820d4369…`, `0xaafb0b82…`, `0x49c43073…`, `0xb77dbe37…` / `0xe6fa0ea808…` |
| B5 log+person: people no | log+person | alice:Y, bob:N, carol:N, dave:Y | [1, 2, 0] | [12.33, 4.46, 0.0] | defeated | no | `0x4d808cd3a2…` / `0xcad492e6…`, `0x10767c10…`, `0x38831101…`, `0x824d36ee…` / - |
| T1 wBLOZ payout 100 after yes | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0x44ef0ac7c6…` / `0x24d2e309…`, `0x44d93bf2…`, `0xb432ad2d…` / `0x96017fd6bf…` |
| T2 wBLOZ payout rejected: nothing moves | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0x3869f8cd29…` / `0x13f0933e…`, `0x0cf04d20…`, `0xabe3a95b…` / - |
| X1 non-member calls execute() | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | executed | yes | `0x7ee5670dd7…` / `0x4d03935d…`, `0x6aac8a51…`, `0x9e93826e…` / `0x16f776c8a1…` |
| X2 live results hidden, payout still runs | linear+person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [1100.0, 10.0, 0.0] | executed | yes | `0x2dc903567d…` / `0x680329f5…`, `0x7f45d59d…`, `0x09135075…` / `0x300b6baef6…` |
| Q1 plain question without payment passes | person | alice:Y, bob:Y, carol:N | [2, 1, 0] | [0.0, 0.0, 0.0] | succeeded | - | `0xb2de00d4f7…` / `0x8f17c20c…`, `0x6d90d3a7…`, `0x187c678e…` / - |
| Q2 plain question without payment rejected | person | alice:N, bob:N, carol:Y | [1, 2, 0] | [0.0, 0.0, 0.0] | defeated | no | `0xc427da10ab…` / `0xb07666fb…`, `0xeae86866…`, `0x4d93684a…` / - |

### Rule, negative and server-side cases

**R rules (one payment vote)**
- propose_tx: `0x3fd43f3187d05864ede08e8db8942bfafe7c758689b8c6240309e2a962288f75`
- votes: `0xc0b04b11f62246a330e490ef8e54c8b709223564dab7113e06c1234c61e76879`, `0xcc38d7cc82d21b12ce1377e59a99c6d123dabd01d6b636fb0c3da8ab0efaba2a`
- treasury: `0xAe800C6Dd88f79b061Aa8Be164773e68e390fE62`
- Stimme vor Beginn (Vertrag): WrongState
- Nicht-Mitglied (Server): Only members who joined before this vote started can vote.
- Nicht-Mitglied (Vertrag): NotMember
- Empfängerin stimmt (Vertrag): RecipientCantVote
- Ohne Voter-ID, nur Person (Server): You need a Block Zero voter ID to vote on chain. Get it on your account page (free).
- Ohne Voter-ID, nur Person (Vertrag): NoVoterId
- Doppelstimme (Vertrag): AlreadyVoted; Server-Antwort: You already voted.
- execute vor Fristende: WrongState
- execute im Timelock: WrongState
- Stimme nach Fristende (Server): This vote is not in the right state for that.; (Vertrag): WrongState
- Verfall nach Gnadenfrist: Zustand expired, execute WrongState, Empfänger unverändert
- Final state: expired

**C cancel by creator after 2 yes votes**
- propose_tx: `0x9ff642a5d6a90e72748440e69771eaecaedb8e790cda9f9185d60d3752814dde`
- cancel_tx: `0x679a73d5bd9844854ac4430ff196fccf1ad090f0014d9af9ce6594617df28f08`
- Final state: cancelled

**V guardian veto after 2 yes votes**
- propose_tx: `0x5edb7d1f053e57ddc0a6e10e46b0881c09d259b2f3e69137babef3062f64a46f`
- veto_tx: `0xb52ce8b914f79f47adad41f672a1b010ca7b64972c0c62d502638be37022eda8`
- Final state: vetoed

**H show_live off**
- propose_tx: `0xbe8693f5b1d451a2267893c9137760c5e9a06dd85390b43ae07eb7de01bfea16`
- Final state: Yes

**N wBLOZ only (negative tests)**
- treasury: `0x6599FE0079d4599320bB16730763D963d0ecB65A`
- BNB an Kasse: abgelehnt ({'code': -32603, 'message': "Error: Transaction reverted: function), Kasse 0 BNB
- Kasse pay(address,address,uint256,uint256) (frank): revert:{'code': -32603, 'message': "Error: Transaction reverted: function selector was 
- Kasse execute(address,uint256,bytes) (frank): revert:{'code': -32603, 'message': "Error: Transaction reverted: function selector was 
- Kasse rescue(address,address,uint256) (founder): revert:{'code': -32603, 'message': "Error: Transaction reverted: function selector was 
- Kasse pay(address,uint256,uint256) (frank): NotGovernor
- Kasse pay(address,uint256,uint256) (founder): NotGovernor
- pay() als Transaktion durch Fremde: abgelehnt, Kasse 1000 tWBLOZ
- Antrag BNB (Vertrag): TokenNotAllowed
- Antrag Fremdtoken (Vertrag): TokenNotAllowed
- Antrag über Deckel (Vertrag): AmountTooHigh
- maxAmount(BNB)=0, WBLOZ()=0x5fbdb2315678afecb367f032d93f642f64180aa3
- Server BNB: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Server DOGE: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Server über Deckel: The maximum per vote is 5000 tWBLOZ.
- Anzeige: Salden {'tWBLOZ': '0'}, Deckel {'tWBLOZ': '5000'}

**S server-side creation checks**
- keine Zählart: Please choose how votes are counted (one BLOZ one vote, one person one vote, or both).
- linear UND log zugleich: Choose linear OR logarithmic balance counting, not both (you can add one person, one vote).
- Betrag über Deckel (5000 tWBLOZ): The maximum per vote is 5000 tWBLOZ.
- Empfänger = Gruppen-Kasse: Please give a valid recipient wallet address (not the group wallet).
- unbekannter Token: Payouts are wBLOZ only (tWBLOZ). Other coins and tokens can't be paid out from a group wallet.
- Mitglied ohne Verwaltungsrecht erstellt Abstimmung: Only the founder or an admin can create votes.
- Nicht-Mitglied erstellt Abstimmung: Only the founder or an admin can create votes.
- Gruppe ohne Wallet: Web-Abstimmung ohne Kette, keine Auszahlung möglich (so gewollt)
- Sichtbarkeit: Standard nur Mitglieder; Gründer-Schalter wallet_public zeigt Adresse, Saldo, Kassenbuch öffentlich; Einzelstimmen nie

**VF verified requirement**
- strikt, nur Wallet: Not all checks pass yet: discord, discord_age, bloz_addr.
- strikt, voll verifiziert: Voter-ID erteilt, tx 0x0e911c3a039a8cb2101b16d314117c109937685084cddb9cc31b1a18eafefbef
- Verified-only-Gruppe, frank (nur Wallet): Link Discord and your BLOZ address to join this Verified-only group (1 of 3).
- Verified-only-Gruppe, dave (voll verifiziert): beigetreten
- Verified-only-Gruppe, alice (Voter-ID, aber ohne Discord/BLOZ-Adresse): Link Discord and your BLOZ address to join this Verified-only group (1 of 3).

**Failed checks:** All checks passed.
