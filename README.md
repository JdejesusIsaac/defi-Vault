Exchange contract

Our Exchange contract can accept liquidity from users, calculate prices in a way that protects from draining, and allows users to swap eth for tokens and back.

Each pair (eth-token) is deployed as an exchange contract and allows to exchange ether to/from only one token.


What’s missing ..

1. Adding new liquidity can cause huge price changes.
2. Liquidity providers are not rewarded; all swaps are free.
3. There’s no way to remove liquidity.
4. No way to swap ERC20 tokens (chained swaps).
5. Factory is still not implemented.

```
