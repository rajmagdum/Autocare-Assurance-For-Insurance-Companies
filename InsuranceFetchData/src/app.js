import Web3 from 'web3';
import QRCode from 'qrcode';
import abi from './contractABI.json';

document.addEventListener('DOMContentLoaded', async () => {
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        try {
            await window.ethereum.enable();
        } catch (error) {
            console.log('User denied account access');
            return;
        }
    } else {
        console.log('No Ethereum wallet detected');
        return;
    }

//contractAddress = '0x4Cf76F2972ea21f040B5007A53436203A32D731D';
    const contractAddress = '0x4Cf76F2972ea21f040B5007A53436203A32D731D';
    const contract = new window.web3.eth.Contract(abi, contractAddress);

    document.getElementById('fetchData').addEventListener('click', async () => {
        try {
            const accounts = await window.web3.eth.getAccounts();
            console.log('Accounts:', accounts);
            
            // Call the request function
            await contract.methods.requestMultipleParameters().send({ from: accounts[0] });
            console.log('Request sent');

            // After data is fetched and the Chainlink node fulfills the request, call the getInsuranceDetails function
            const details = await contract.methods.getInsuranceDetails().call();
            console.log('Details fetched:', details);

            const SCALING_FACTOR = 100000;

            const vehicleId = Number(details[0]) / Number(SCALING_FACTOR);
            const engineHealth = Number(details[1]) === Number(SCALING_FACTOR) ? 'Good' : 'Bad';
            const timestamp = Number(details[2]) / Number(SCALING_FACTOR);

            const premium = details[3];

            document.getElementById('vehicleId').textContent = vehicleId;
            document.getElementById('engineHealth').textContent = engineHealth;
            document.getElementById('timestamp').textContent = timestamp;
            document.getElementById('premium').textContent = premium + ' euros';

            const qrData = `Vehicle ID: ${vehicleId}\nEngine Health: ${engineHealth}\nTimestamp: ${timestamp}\nInsurance Premium: ${premium} euros`;
            QRCode.toCanvas(document.getElementById('qrcode'), qrData, function (error) {
                if (error) console.error(error);
                console.log('QR code generated!');
                document.getElementById('qrcode').style.display = 'inline-block';
            });
        } catch (error) {
            console.error('Error:', error);
        }
    });
});
