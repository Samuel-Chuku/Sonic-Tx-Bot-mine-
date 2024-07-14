#!/bin/bash

BOLD_BLUE='\033[1;34m'
NC='\033[0m'

if ! command -v node &> /dev/null
then
    echo -e "${BOLD_BLUE}Node.js is not installed. Installing Node.js...${NC}"
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${BOLD_BLUE}Node.js is already installed.${NC}"
fi

if ! command -v npm &> /dev/null
then
    echo -e "${BOLD_BLUE}npm is not installed. Installing npm...${NC}"
    sudo apt-get install -y npm
else
    echo -e "${BOLD_BLUE}npm is already installed.${NC}"
fi

echo -e "${BOLD_BLUE}Creating project directory and navigating into it${NC}"
mkdir -p SonicBatchTx
cd SonicBatchTx

echo -e "${BOLD_BLUE}Initializing a new Node.js project${NC}"
npm init -y

echo -e "${BOLD_BLUE}Installing required packages${NC}"
npm install @solana/web3.js chalk bs58

echo -e "${BOLD_BLUE}Creating the Node.js script file${NC}"
cat << EOF > zun.mjs
import readline from 'readline';
import web3 from "@solana/web3.js";
import chalk from "chalk";
import bs58 from "bs58";

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Enter your Solana wallet private key: ', (privkey) => {
    const connection = new web3.Connection("https://devnet.sonic.game", 'confirmed');
    const from = web3.Keypair.fromSecretKey(bs58.decode(privkey));
    const to = web3.Keypair.generate();

    (async () => {
        const transaction = new web3.Transaction().add(
            web3.SystemProgram.transfer({
                fromPubkey: from.publicKey,
                toPubkey: to.publicKey,
                lamports: web3.LAMPORTS_PER_SOL * 0.001,
            })
        );
        const txCount = 20;
        let i = 0;
        const interval = setInterval(async () => {
            if (i < txCount) {
                const signature = await web3.sendAndConfirmTransaction(
                    connection,
                    transaction,
                    [from]
                );
                i++;
                console.log(chalk.blue('Tx hash :'), signature);
            } else {
                clearInterval(interval);
            }
        }, 90000);
        console.log("");
        const randomDelay = Math.floor(Math.random() * 3) + 1;
        await new Promise(resolve => setTimeout(resolve, randomDelay * 1000));
    })();

    rl.close();
});
EOF

echo -e "${BOLD_BLUE}Executing the Node.js script${NC}"
node zun.mjs
