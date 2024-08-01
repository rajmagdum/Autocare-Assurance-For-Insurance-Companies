# Autocare-Assurance-For-Insurance-Companies
This project aims to ensure proper vehicle maintenance to help customers avail of lower insurance premiums. It integrates a Solidity smart contract, a machine learning model, and a frontend application to provide a complete solution for vehicle health tracking and insurance premium calculation.

## Project Structure
1) Solidity Smart Contract - This smart contract fetches vehicle health parameters from a Chainlink oracle and calculates insurance premiums based on the engine health. Smart contract deployed on Remix.
2) ML Model - This folder contains the dataset used for training the machine learning model, the Jupyter notebook used for training, and the serialized model file.
3) Insurance Flask API - A Flask API that serves a form for inputting vehicle details, predicts engine health using the machine learning model, and generates the required JSON data. Deployed on Render.
   - https://insurancefinal.onrender.com/
4) Insurance FetchData - A frontend application that connects to the Solidity smart contract using Web3.js, fetches vehicle health data, and displays the insurance details. Deployed on Vercel.
   - https://insurance-data-fetch.vercel.app/
     
### Prerequisites
Node.js and npm,
Python and Flask,
MetaMask: Install the MetaMask browser extension from metamask.io

### Funding your Wallet
Sepholia ETH and LINK tokens faucet - https://faucets.chain.link/
